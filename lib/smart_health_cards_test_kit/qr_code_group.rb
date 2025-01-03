require_relative 'utils/chunking_utils'

module SmartHealthCardsTestKit
  class QrCodeGroup < Inferno::TestGroup
    id :shc_qr_code_group
    title 'Download and validate a health card via QR code'
    run_as_group

    #input :file_download_url

    test do
      id :qr_code_scan_test
      title 'Scan QR Code'
      description %(
        Issuers can represent an individual JWS inside a Health Card available as a QR code.
      )

      # Assign a name to the incoming request so that it can be inspected by
      # other tests.
      receives_request :post_qr_code

      run do
        run_id = SecureRandom.uuid

        wait(
          identifier: run_id,
          message: %(
            Tester can either scan a QR code using webcam (link 1) or upload a presaved QR code
            from local system (link 2).

            After a QR code is scanned or uploaded, testing will resume at the next test.

            * [Follow this link to scan QR code](#{Inferno::Application['base_url']}/custom/smart_health_cards_test_suite/scan_qr_code?id=#{run_id}).
            * [Follow this link to upload QR code from a saved image file](#{Inferno::Application['base_url']}/custom/smart_health_cards_test_suite/upload_qr_code?id=#{run_id})
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
            * decimal representation of "C" (e.g., 1 for the first chunk, 2 for the second chunk,
              and so on)
            * plus the fixed string /
            * plus decimal representation of "N" (e.g., 2 if there are two chunks in total, 3 if
              there three chunks in total, and so on)
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
      description %(
        Each JWS string that appears in the .verifiableCredential[] of a .smart-health-card file
        can be represented as a QR code
      )
      input :qr_code_content
      output :credential_strings

      run do
        skip_if qr_code_content.blank?, 'No QR code chunks received'

        vc = SmartHealthCardsTestKit::Utils::ChunkingUtils.qr_chunks_to_jws([qr_code_content])

        assert vc.present?, 'QR code does not have valid verifiable credential string'

        output credential_strings: vc
      end
    end


    test from: :shc_header_verification_test

    test from: :shc_signature_verification_test

    test from: :shc_payload_verification_test

    test from: :shc_fhir_validation_test
  end
end
