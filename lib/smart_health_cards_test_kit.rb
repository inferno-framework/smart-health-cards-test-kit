require_relative 'smart_health_cards/file_download_group'
require_relative 'smart_health_cards/qr_code_group'
require_relative 'smart_health_cards/fhir_operation_group'

module SmartHealthCards
  class Suite < Inferno::TestSuite
    id :smart_health_cards_test_suite
    title 'SMART Health Cards'
    description %(
      The US Core Test Kit tests systems for their conformance to the [SMART Health Cards Framework]
      (https://spec.smarthealth.cards/) and [SMART Health Cards and Links FHIR Implementation Guide
      v1.0.0-ballot](https://build.fhir.org/ig/HL7/smart-health-cards-and-links/).
    )

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

    my_html = File.read(File.join(__dir__, 'new.html'))
    my_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [my_html]] }
    route(:get, '/scan_qr_code', my_html_route_handler)

    my_js = File.read(File.join(__dir__, 'qr-scanner.min.js'))
    my_js_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [my_js]] }
    route(:get, '/qr-scanner.min.js', my_js_route_handler)

    my_js_worker = File.read(File.join(__dir__, 'qr-scanner-worker.min.js'))
    my_js_worker_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [my_js_worker]] }
    route(:get, '/qr-scanner-worker.min.js', my_js_worker_route_handler)

    my_js_worker_map = File.read(File.join(__dir__, 'qr-scanner-worker.min.js.map'))
    my_js_worker_map_route_handler = proc { [200, { 'Content-Type' => 'text/javascript' }, [my_js_worker_map]] }
    route(:get, '/qr-scanner-worker.min.js.map', my_js_worker_map_route_handler)

    upload_html = File.read(File.join(__dir__, '../views/upload_qr_code.html'))
    upload_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [upload_html]] }
    route(:get, '/upload_qr_code', upload_html_route_handler)


    # Tests and TestGroups
    group from: :shc_file_download_group
    group from: :shc_qr_code_group
    group from: :shc_fhir_operation_group
  end
end
