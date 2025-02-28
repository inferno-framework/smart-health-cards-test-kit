require 'json'

require_relative 'version'

require_relative 'utils/jws'
require_relative 'health_card'

require_relative 'shc_fhir_validation'
require_relative 'shc_header_verification'
require_relative 'shc_payload_verification'
require_relative 'shc_signature_verification'

require_relative 'file_download_group'
require_relative 'qr_code_group'
require_relative 'fhir_operation_group'

module SmartHealthCardsTestKit
  class SmartHealthCardsTestSuite < Inferno::TestSuite
    id :smart_health_cards
    title 'SMART Health Cards'
    description %(
      The SMART Health Cards tests systems for their conformance to the
      [SMART Health Cards Framework v1.4.0](https://spec.smarthealth.cards/)
    )

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
      },
      {
        label: 'SMART Health Cards Framework',
        url: 'https://spec.smarthealth.cards/'
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

    scan_qr_code_html = File.read(File.join(__dir__, './views/scan_qr_code.html'))
    scan_qr_code_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [scan_qr_code_html]] }
    route(:get, '/scan_qr_code', scan_qr_code_html_route_handler)

    qr_scanner = File.read(File.join(__dir__, './javascript/qr-scanner.min.js'))
    qr_scanner_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [qr_scanner]] }
    route(:get, '/qr-scanner.min.js', qr_scanner_route_handler)

    qr_scanner_worker = File.read(File.join(__dir__, './javascript/qr-scanner-worker.min.js'))
    qr_scanner_worker_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [qr_scanner_worker]] }
    route(:get, '/qr-scanner-worker.min.js', qr_scanner_worker_route_handler)

    js_qr = File.read(File.join(__dir__, './javascript/jsQR.js'))
    js_qr_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [js_qr]] }
    route(:get, '/jsqr.js', js_qr_route_handler)

    upload_html = File.read(File.join(__dir__, './views/upload_qr_code.html'))
    upload_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [upload_html]] }
    route(:get, '/upload_qr_code', upload_html_route_handler)

    # Tests and TestGroups
    group from: :shc_file_download_group
    group from: :shc_fhir_operation_group
    group from: :shc_qr_code_group
  end
end
