require 'health_cards'
require 'json'
require_relative 'shc_payload_verification'
require_relative 'shc_header_verification'
require_relative 'shc_fhir_validation'
require_relative 'shc_signature_verification'

module SmartHealthCards
  class FileDownloadGroup < Inferno::TestGroup
    id :shc_file_download_group
    title 'Download and validate a health card via file download'
    run_as_group

    input :file_download_url

    test do
      id :health_card_download_test
      title 'Health card can be downloaded'
      description %(
        To facilitate User Retrieves Health Cards workflow, the issuer can include a
        link to help the user download the credentials directly. Contents should be a JSON object.
      )
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
      description %(
        The downloded file SHALL be provided with a MIME type of application/smart-health-card.
        (e.g., web servers SHALL include Content-Type: application/smart-health-card as
        an HTTP Response containing a Health Card)
      )
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
      description %(
        The downloaded file SHALL be served with a .smart-health-card file extension.
      )
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
      description %(
        Contents of the downloaded file should be a JSON object containing an array of Verifiable Credential JWS strings.
      )
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

    test from: :shc_header_verification_test

    test from: :shc_signature_verification_test

    test from: :shc_payload_verification_test

    test from: :shc_fhir_validation_test
  end
end
