require 'health_cards'
require 'json'
require_relative 'shc_payload_verification'
require_relative 'shc_header_verification'
require_relative 'shc_fhir_validation'

module SmartHealthCards
  class QrCodeGroup < Inferno::TestGroup
    id :shc_qr_code_group
    title 'Download and validate a health card via QR code'
    run_as_group

    #input :file_download_url

    test do
      id :qr_code_scan_test
      title 'Scan QR Code'
      description 'The health card can be scanned from QR code and is a valid JSON object.'

      # Assign a name to the incoming request so that it can be inspected by
      # other tests.
      receives_request :post_qr_code

      run do
        run_id = SecureRandom.uuid

        wait(
          identifier: run_id,
          message: %(
            [Follow this link to scan QR code](#{Inferno::Application['base_url']}/custom/smart_health_cards_test_suite/scan_qr_code?id=#{run_id}).

            [Follow this link to upload QR code from a image file](#{Inferno::Application['base_url']}/custom/smart_health_cards_test_suite/upload_qr_code?id=#{run_id})
          )
        )
      end
    end

    test do
      id :qr_code_segement_test
      title 'QR Code Segment Tests'
      description %(
        QR Code SHALL have these segements:

        * A segment encoded with bytes mode consisting of
          * the fixed string shc:/
          * plus (only if more than one chunk is required; note this feature is deprecated)
            * decimal representation of "C" (e.g., 1 for the first chunk, 2 for the second chunk, and so on)
            * plus the fixed string /
            * plus decimal representation of "N" (e.g., 2 if there are two chunks in total, 3 if there three chunks in total, and so on)
            * plus the fixed string /
        * A segment encoded with numeric mode consisting of the characters 0-9.
      )

      # Make the incoming request from the previous test available here.
      uses_request :post_qr_code
      output :qr_code_content

      run do
        request_body = request.request_body
        assert request_body.present?, 'Could not read QR code'
        assert_valid_json(request_body)

        payload = JSON.parse(request_body)
        assert payload.present?, 'Invalid JSON payload'

        qr_code_content = payload['qr_code_content']
        assert qr_code_content.present?, 'QR code is empty'

        health_card_pattern = /^shc:\/(?<multipleChunks>(?<chunkIndex>[0-9]+)\/(?<chunkCount>[0-9]+)\/)?[0-9]+$/;

        assert health_card_pattern.match?(qr_code_content), "QR does not match the required pattern #{health_card_pattern.inspect}"

        output qr_code_content: qr_code_content
      end
    end

    test do
      id :qr_code_verifiable_credential_test
      title 'QR Code contains an array of Verifiable Credential strings'

      input :qr_code_content
      output :credential_strings

      run do
        skip_if qr_code_content.blank?, 'No QR code chunks received'

        vc = HealthCards::ChunkingUtils.qr_chunks_to_jws([qr_code_content])
        assert vc.present?, 'QR code does not have valid verifiable credential string'

        output credential_strings: vc
      end
    end


    test from: :shc_header_verification_test

    test from: :shc_payload_verification_test

    test from: :shc_fhir_validation_test
  end
end
