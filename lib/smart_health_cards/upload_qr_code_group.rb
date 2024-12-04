require 'health_cards'
require 'json'
require_relative 'shc_payload_verification'
require_relative 'shc_header_verification'

module SmartHealthCards
  class UploadQrCodeGroup < Inferno::TestGroup
    id :shc_upload_qr_code_group
    title 'Download and validate a health card via uploading QR code image'
    run_as_group

    #input :file_download_url

    test do
      id :qr_code_upload_test
      title 'Upload QR Code'
      description 'The health card can be scanned from QR code and is a valid JSON object.'

      # Assign a name to the incoming request so that it can be inspected by
      # other tests.
      receives_request :upload_qr_file

      run do
        run_id = SecureRandom.uuid

        wait(
          identifier: run_id,
          message: %(
            [Follow this link to upload QR code from a image file](#{Inferno::Application['base_url']}/custom/smart_health_cards_test_suite/upload_qr_code?id=#{run_id})
          )
        )
      end
    end

    test do
      id '123'

      # Make the incoming request from the previous test available here.
      uses_request :upload_qr_file

      title 'QR Code Segment Tests'
      description %(
        QR Code SHALL have two segements:

        * A segment encoded with bytes mode consisting of
          * the fixed string shc:/
        * A segment encoded with numeric mode consisting of the characters 0-9.
      )

      run do
        # require 'debug/open_nonstop'
        # debugger
        qr_code_content = request.body['qr_code_content']
        assert qr_code_content.present? 'Could not read QR code'
      end
    end
    # test do
    #   id :content_type_test
    #   title 'Response contains correct Content-Type of application/smart-health-card'
    #   uses_request :shc_file_download

    #   run do
    #     skip_if request.status != 200, 'Health card not successfully downloaded'

    #     content_type = request.response_header('Content-Type')

    #     assert content_type.present?, 'Response did not include a Content-Type header'
    #     assert content_type.value.match?(%r{\Aapplication/smart-health-card(\z|\W)}),
    #            "Content-Type header was '#{content_type.value}' instead of 'application/smart-health-card'"
    #   end
    # end

    # test do
    #   id :file_extension_test
    #   title 'Health card is provided as a file download with a .smart-health-card extension'
    #   uses_request :shc_file_download

    #   run do
    #     skip_if request.status != 200, 'Health card not successfully downloaded'

    #     pass_if request.url.ends_with?('.smart-health-card')

    #     content_disposition = request.response_header('Content-Disposition')
    #     assert content_disposition.present?,
    #            "Url did not end with '.smart-health-card' and response did not include a Content-Disposition header"

    #     attachment_pattern = /\Aattachment;/
    #     assert content_disposition.value.match?(attachment_pattern),
    #            "Url did not end with '.smart-health-card' and " \
    #            "Content-Disposition header does not indicate file should be downloaded: '#{content_disposition}'"

    #     extension_pattern = /filename=".*\.smart-health-card"/
    #     assert content_disposition.value.match?(extension_pattern),
    #            "Url did not end with '.smart-health-card' and Content-Disposition header does not indicate " \
    #            "file should have a '.smart-health-card' extension: '#{content_disposition}'"
    #   end
    # end

    # test do
    #   id :verifiable_credential_test
    #   title 'Response contains an array of Verifiable Credential strings'
    #   uses_request :shc_file_download
    #   output :credential_strings

    #   run do
    #     skip_if request.status != 200, 'Health card not successfully downloaded'

    #     body = JSON.parse(response[:body])
    #     assert body.include?('verifiableCredential'),
    #            "Health card does not contain 'verifiableCredential' field"

    #     vc = body['verifiableCredential']

    #     assert vc.is_a?(Array), "'verifiableCredential' field must contain an Array"
    #     assert vc.length.positive?, "'verifiableCredential' field must contain at least one verifiable credential"

    #     output credential_strings: vc.join(',')

    #     pass "Received #{vc.length} verifiable #{'credential'.pluralize(vc.length)}"
    #   end
    # end

    # test from: :shc_header_verification_test

    # test from: :shc_payload_verification_test

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
