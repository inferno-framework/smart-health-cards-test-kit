module SmartHealthCardsTestKit
  class FHIROperation < Inferno::TestGroup
    id :shc_fhir_operation_group
    title 'Download and validate a health card via FHIR $health-cards-issue operation'
    run_as_group

    input :base_fhir_url, :patient_id

    fhir_client do
      url :base_fhir_url
    end

    test do
      title 'Server advertises health card support in its SMART configuration'
      description %(
        A SMART on FHIR Server capable of issuing VCs according to this specification SHALL
        advertise its support by adding the health-cards capability to its /.well-known/smart-configuration
        JSON file.
      )
      id :smart_configuration_test

      run do
        get("#{base_fhir_url}/.well-known/smart-configuration")

        assert_response_status(200)
        assert_valid_json(response[:body])

        smart_configuration = JSON.parse(response[:body])

        assert smart_configuration['capabilities']&.include?('health-cards'),
               "SMART configuration does not list support for 'health-cards' capability"
      end
    end

    test do
      title 'Server advertises $health-cards-issue operation support in its CapabilityStatement'
      description %(
        A SMART on FHIR Server capable of issuing VCs according to this specification SHOULD
        advertise its support of $health-cards-issue operation by adding the operation to its
        CapabilityStatement.
      )
      id :capabilitystatement_test
      optional

      run do
        fhir_get_capability_statement

        assert_response_status(200)

        operations = resource.rest&.flat_map do |rest|
          rest.resource
            &.select { |r| r.type == 'Patient' && r.respond_to?(:operation) }
            &.flat_map(&:operation)
        end&.compact

        operation_defined = operations.any? { |operation| operation.name == 'health-cards-issue' }

        assert operation_defined,
               'Server CapabilityStatement did not declare support for $health-cards-issue operation ' \
               'on the Patient resource.'
      end
    end

    test do
      title 'Server returns a health card from the $health-cards-issue operation'
      description %(
        For a more seamless user experience when FHIR API connections are already in place,
        results may also be conveyed through a FHIR API $health-cards-issue operation
      )
      id :health_cards_issue_operation_test
      output :credential_strings

      run do
        request_params = FHIR::Parameters.new(
          parameter: [
            {
              name: 'credentialType',
              valueUri: 'https://smarthealth.cards#covid19'
            }
          ]
        )
        fhir_operation("/Patient/#{patient_id}/$health-cards-issue", body: request_params)

        assert_response_status((200..207).to_a)
        assert_resource_type(:parameters)

        hc_parameters = resource.parameter.select { |parameter| parameter.name == 'verifiableCredential' }

        assert hc_parameters.present?, 'No COVID-19 health cards were returned'
        credential_strings = hc_parameters.map(&:value).join(',')

        output credential_strings: credential_strings

        count = hc_parameters.length

        pass "#{count} verifiable #{'credential'.pluralize(count)} received"
      end
    end

    test from: :shc_header_verification_test
    test from: :shc_payload_verification_test
    test from: :shc_signature_verification_test
    test from: :shc_fhir_validation_test
  end
end
