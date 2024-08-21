
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

    test do
      id :verifiable_credential_test
      title 'Response contains an array of Verifiable Credential strings'
      uses_request :shc_file_download
      output :credential_strings

      run do
        skip_if request.status != 200, 'Health card not successfully downloaded'

        body = JSON.parse(response[:body])
        assert body.include?('verifiableCredential'),
               "Health card does not contain 'verifiableCredential' field"

        vc = body['verifiableCredential']

        assert vc.is_a?(Array), "'verifiableCredential' field must contain an Array"
        assert vc.length.positive?, "'verifiableCredential' field must contain at least one verifiable credential"

        output credential_strings: vc.join(',')

        pass "Received #{vc.length} verifiable #{'credential'.pluralize(vc.length)}"
      end
    end

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
