module SmartHealthCards
  class SHCPayloadVerification < Inferno::Test
    id :shc_payload_verification
    title 'Verify the correct SHC payload'
    uses_request :shc_file_download
    input :credential_strings

    run do
      skip_if request.status != 200, 'Health card not successfully downloaded'

      credential_strings.split(',').each do |credential|
        raw_payload = HealthCards::JWS.from_jws(credential).payload
        assert raw_payload&.length&.positive?, 'No payload found'

        decompressed_payload =
        begin
          Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(raw_payload)
        rescue Zlib::DataError
          assert false, 'Payload compression error. Unable to inflate payload.'
        end

        assert decompressed_payload.length.positive?, 'Payload compression error. Unable to inflate payload.'

        raw_payload_length = raw_payload.length #TODO confirm this is the correct length to use
        decompressed_payload_length = decompressed_payload.length

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
      end
    end
  end
end