require 'json'

require_relative 'smart_health_cards_test_kit/version'

require_relative 'smart_health_cards_test_kit/utils/jws'
require_relative 'smart_health_cards_test_kit/health_card'

require_relative 'smart_health_cards_test_kit/shc_fhir_validation'
require_relative 'smart_health_cards_test_kit/shc_header_verification'
require_relative 'smart_health_cards_test_kit/shc_payload_verification'
require_relative 'smart_health_cards_test_kit/shc_signature_verification'

require_relative 'smart_health_cards_test_kit/file_download_group'
require_relative 'smart_health_cards_test_kit/qr_code_group'
require_relative 'smart_health_cards_test_kit/fhir_operation_group'

module SmartHealthCardsTestKit
  class SmartHealthCardsTestSuite < Inferno::TestSuite
    id :smart_health_cards
    title 'SMART Health Cards'
    description %(
      The SMART Health Cards Test Kit tests systems for their conformance to the
      [SMART Health Cards Framework v1.4.0](https://spec.smarthealth.cards/)
    )
    version VERSION
    links [
      {
        label: 'Report Issue',
        url: 'https://github.com/inferno-framework/smart-health-cards-test-kit/issues'
      },
      {
        label: 'Open Source',
        url: 'https://github.com/inferno-framework/smart-health-cards-test-kit'
      },
      {
        label: 'Download',
        url: 'https://github.com/inferno-framework/smart-health-cards-test-kit/releases'
      }
    ]

    # All FHIR validation requsets will use this FHIR validator
    fhir_resource_validator do
      # igs 'identifier#version' # Use this method for published IGs/versions
      # igs 'igs/filename.tgz'   # Use this otherwise

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    # HTTP Routes
    resume_test_route :post, '/post_qr_code' do |request|
      request.query_parameters['id']
    end

    scan_qr_code_html = File.read(File.join(__dir__, './smart_health_cards_test_kit/views/scan_qr_code.html'))
    scan_qr_code_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [scan_qr_code_html]] }
    route(:get, '/scan_qr_code', scan_qr_code_html_route_handler)

    qr_scanner = File.read(File.join(__dir__, './smart_health_cards_test_kit/javascript/qr-scanner.min.js'))
    qr_scanner_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [qr_scanner]] }
    route(:get, '/qr-scanner.min.js', qr_scanner_route_handler)

    qr_scanner_worker = File.read(File.join(__dir__, './smart_health_cards_test_kit/javascript/qr-scanner-worker.min.js'))
    qr_scanner_worker_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [qr_scanner_worker]] }
    route(:get, '/qr-scanner-worker.min.js', qr_scanner_worker_route_handler)

    js_qr = File.read(File.join(__dir__, './smart_health_cards_test_kit/javascript/jsQR.js'))
    js_qr_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [js_qr]] }
    route(:get, '/jsqr.js', js_qr_route_handler)

    upload_html = File.read(File.join(__dir__, './smart_health_cards_test_kit/views/upload_qr_code.html'))
    upload_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [upload_html]] }
    route(:get, '/upload_qr_code', upload_html_route_handler)

    # Tests and TestGroups
    group from: :shc_file_download_group
    group from: :shc_fhir_operation_group
    group from: :shc_qr_code_group
  end
end
