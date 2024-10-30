require 'health_cards'
require 'json'
module SmartHealthCards
  class FileDownloadGroup < Inferno::TestGroup
    id :shc_file_download_group
    title 'Download and validate a health card via file download'

    input :file_download_url

    test do
      id :health_card_download_test
      title 'Health card can be downloaded'
      description 'The health card can be downloaded and is a valid JSON object'
      makes_request :shc_file_download

      run do
        get(file_download_url, name: :shc_file_download)

        assert_response_status(200)
        assert_valid_json(response[:body])
      end
    end

    test do
      id :content_type_test
      title 'Response contains correct Content-Type of application/smart-health-card'
      uses_request :shc_file_download

      run do
        skip_if request.status != 200, 'Health card not successfully downloaded'

        content_type = request.response_header('Content-Type')

        assert content_type.present?, 'Response did not include a Content-Type header'
        assert content_type.value.match?(%r{\Aapplication/smart-health-card(\z|\W)}),
               "Content-Type header was '#{content_type.value}' instead of 'application/smart-health-card'"
      end
    end

    test do
      id :file_extension_test
      title 'Health card is provided as a file download with a .smart-health-card extension'
      uses_request :shc_file_download

      run do
        skip_if request.status != 200, 'Health card not successfully downloaded'

        pass_if request.url.ends_with?('.smart-health-card')

        content_disposition = request.response_header('Content-Disposition')
        assert content_disposition.present?,
               "Url did not end with '.smart-health-card' and response did not include a Content-Disposition header"

        attachment_pattern = /\Aattachment;/
        assert content_disposition.value.match?(attachment_pattern),
               "Url did not end with '.smart-health-card' and " \
               "Content-Disposition header does not indicate file should be downloaded: '#{content_disposition}'"

        extension_pattern = /filename=".*\.smart-health-card"/
        assert content_disposition.value.match?(extension_pattern),
               "Url did not end with '.smart-health-card' and Content-Disposition header does not indicate " \
               "file should have a '.smart-health-card' extension: '#{content_disposition}'"
      end
    end

    #TODO: test that response is a JSON object

    test do
      id :verifiable_credential_test
      title 'Response contains an array of Verifiable Credential strings'
      uses_request :shc_file_download
      output :credential_strings

      run do
        skip_if request.status != 200, 'Health card not successfully downloaded'

        body = JSON.parse(response[:body])
        #puts body
        assert body.include?('verifiableCredential'),
               "Health card does not contain 'verifiableCredential' field"

        vc = body['verifiableCredential']

        assert vc.is_a?(Array), "'verifiableCredential' field must contain an Array"
        assert vc.length.positive?, "'verifiableCredential' field must contain at least one verifiable credential"

        output credential_strings: vc.join(',')

        pass "Received #{vc.length} verifiable #{'credential'.pluralize(vc.length)}"
      end
    end

    test do
      id :decode_credential_test
      title 'Decode the JWS payload'
      uses_request :shc_file_download
      input :credential_strings
      output :decoded_jws_payload

      run do
        skip_if request.status != 200, 'Health card not successfully downloaded'
        puts 'beginning of decode_credential_test'

        credential_strings.split(',').each do |credential|
          raw_payload = HealthCards::JWS.from_jws(credential).payload
          assert raw_payload&.length&.positive?, 'No payload found'

          decompressed_payload =
          begin
            Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(raw_payload)
          rescue Zlib::DataError
            assert false, 'Payload compression error. Unable to inflate payload.'
          end
          puts 'decompressed_payload = ' + decompressed_payload.to_s

          assert decompressed_payload.length.positive?, 'Payload compression error. Unable to inflate payload.'

          raw_payload_length = raw_payload.length #TODO this might not be the correct length to use
          decompressed_payload_length = decompressed_payload.length

          puts 'raw_payload_length = ' + raw_payload_length.to_s
          puts 'decompressed_payload_length = ' + decompressed_payload_length.to_s

          warning do
            assert raw_payload_length <= decompressed_payload_length,
                   "Payload may not be properly minified. Received a payload with length #{raw_payload_length}, " \
                   "but was able to generate a payload with length #{decompressed_payload_length}"
          end

          assert_valid_json decompressed_payload, 'Payload is not valid JSON'

          payload = JSON.parse(decompressed_payload)

          warning do
            nbf = payload['nbf']
            assert nbf.present?, "Payload does not include an 'nbf' claim"
            assert nbf.is_a?(Numeric), "Expected 'nbf' claim to be Numeric, but found #{nbf.class}"
            issue_time = Time.at(nbf).to_datetime
            puts 'issue_time = ' + issue_time.to_s
            assert issue_time < DateTime.now, "'nbf' is in the future: #{issue_time.rfc822}"
          end

          vc = payload['vc']
          assert vc.is_a?(Hash), "Expected 'vc' claim to be a JSON object, but found #{vc.class}"
          type = vc['type']

          warning do
            assert type.is_a?(Array), "Expected 'vc.type' to be an array, but found #{type.class}"
            assert type.include?('https://smarthealth.cards#health-card'),
                  "'vc.type' does not include 'https://smarthealth.cards#health-card'"
          end

          ## asdf

          subject = vc['credentialSubject']
          assert subject.is_a?(Hash), "Expected 'vc.credentialSubject' to be a JSON object, but found #{subject.class}"

          warning do
            assert subject['fhirVersion'].present?, "'vc.credentialSubject.fhirVersion' not provided"
          end

          raw_bundle = subject['fhirBundle']
          assert raw_bundle.is_a?(Hash), "Expected 'vc.fhirBundle' to be a JSON object, but found #{raw_bundle.class}"

          resource_scheme_regex = /\Aresource:\d+\z/
          warning do
            urls = raw_bundle['entry'].map { |entry| entry['fullUrl'] }
            bad_urls = urls.reject { |url| url.match?(resource_scheme_regex) }
            assert bad_urls.empty?,
                  "The following Bundle entry urls do not use short resource-scheme URIs: #{bad_urls.join(', ')}"
          end

          bundle = FHIR::Bundle.new(raw_bundle)
          resources = bundle.entry.map(&:resource)
          bundle.entry.each { |entry| entry.resource = nil }
          resources << bundle

          resources.each do |resource|
            warning { assert resource.id.nil?, "#{resource.resourceType} resource should not have an 'id' element" }

            if resource.respond_to? :text
              warning { assert resource.text.nil?, "#{resource.resourceType} resource should not have a 'text' element" }
            end

            resource.each_element(resource) do |value, meta, path|
              case meta['type']
              when 'CodeableConcept'
                warning { assert value.text.nil?, "#{resource.resourceType} should not have a #{path}.text element" }
              when 'Coding'
                warning do
                  assert value.display.nil?, "#{resource.resourceType} should not have a #{path}.display element"
                end
              when 'Reference'
                warning do
                  next if value.reference.nil?

                  assert value.reference.match?(resource_scheme_regex),
                        "#{resource.resourceType}.#{path}.reference is not using the short resource URI scheme: " \
                        "#{value.reference}"
                end
              when 'Meta'
                hash = value.to_hash
                warning do
                  assert hash.length == 1 && hash.include?('security'),
                        "If present, Bundle 'meta' field should only include 'security', " \
                        "but found: #{hash.keys.join(', ')}"
                end
              end
            end
          end








          #this assumes only one credential
          output decoded_jws_payload: decompressed_payload.to_s

          #TODO some kind of pass/fail criteria for this test

        end
        puts 'end of decode_credential_test'
      end
    end

    #test do
      #id :decode_credential_test
      #title 'Decoded JWS payload contains a JSON object'
      #uses_request :shc_file_download

      #run do
      #  skip_if request.status != 200, 'Health card not successfully downloaded'

        #response[:body] is a json object. try setting jws to the value of the verifiableCredential key
        #parsed_response_body = JSON.parse(response[:body])
        #jws = parsed_response_body['verifiableCredential'][0]
        
        #get((url+'.well-known/jwks.json'), name: :jwks_file_download)
        #parsed_jwks_keys = JSON.parse(response[:body])
        #public_key = parsed_jwks_keys['keys'][0]
        #public_key = '{"x":"xHIk_yK0GhVqYtg5dnsGl2xfw3dB7QWmm0BNPqynZMM","y":"_06b-oSWC6BbZ5rd2O4nCgvKdzWq6x43B00iWMEuYno","kty":"EC","crv":"P-256","kid":"4HUb2arvhTSXssEoMs2G5ToDpsYvsj7h5wT_3zNEtug","use":"sig","alg":"ES256"}'

        #puts 'jws = ' + jws
        #puts 'public_key = ' + public_key

        #verifier = HealthCards::Verifier.new
        #verifier.verify(jws)

        #JWS = HealthCards::JWS.from_jws(jws, public_key)
        #JWS.public_key = public_key

        #keys = HealthCards::Key.new(my_jwks_keys)
        #verifier = HealthCards::Verifier.new(keys)
        # By default the verifier will search for and resolve public keys to verify credentials
        #verifier.verify(jws)

      #end
    #end

    #next test: JSON Object has correct value




    # test from: :vc_headers do
    #   id 'vci-file-05'
    # end

    # test from: :vc_signature_verification do
    #   id 'vci-file-06'
    # end

    # test from: :vc_payload_verification do
    #   id 'vci-file-07'
    # end

    # test from: :vc_fhir_verification do
    #   id 'vci-file-08'
    # end
  end
end
