require_relative 'smart_health_cards/file_download_group'
require_relative 'smart_health_cards/qr_code_group'

module SmartHealthCards
  class Suite < Inferno::TestSuite
    id :smart_health_cards_test_suite
    title 'SMART Health Cards'
    description 'Inferno SMART Health Cards test suite.'

    # These inputs will be available to all tests in this suite
    # input :url,
    #       title: 'FHIR Server Base Url'

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    # All FHIR requests in this suite will use this FHIR client
    fhir_client do
      url :url
      oauth_credentials :credentials
    end

    # All FHIR validation requsets will use this FHIR validator
    fhir_resource_validator do
      # igs 'identifier#version' # Use this method for published IGs/versions
      # igs 'igs/filename.tgz'   # Use this otherwise

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    resume_test_route :post, '/post_qr_code' do |request|
      request.query_parameters['id']
    end

    my_html = File.read(File.join(__dir__, 'new.html'))
    my_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [my_html]] }

    # Serve an html page at INFERNO_PATH/my_test_suite/custom/my_html_page
    route(:get, '/scan_qr_code', my_html_route_handler)


    # resume_test_route :post, '/upload_qr_file' do |request|
    #   request.query_parameters['id']
    # end

    upload_html = File.read(File.join(__dir__, 'upload_qr_code.html'))
    upload_html_route_handler = proc { [200, { 'Content-Type' => 'text/html' }, [upload_html]] }

    route(:get, '/upload_qr_code', upload_html_route_handler)

    # Tests and TestGroups can be written in separate files and then included
    # using their id
    group from: :shc_file_download_group
    group from: :shc_qr_code_group
  end
end
