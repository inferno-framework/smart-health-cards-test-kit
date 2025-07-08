RSpec.describe SmartHealthCardsTestKit::SHCFHIRValidation do
  let(:suite_id) { 'smart_health_cards' }

  describe 'health_card_fhir_validation_test' do
    let(:test) { find_test suite, 'shc_fhir_validation_test' }
    let(:url) { 'http://example.com/hc' }
    let(:operation_outcome_success) do
      {
        outcomes: [{
          issues: []
        }],
        sessionId: test_session.id
      }
    end
    let(:fhir_bundle_corrina_rowe) do
      FHIR::Bundle.new(
        type: 'collection',
        entry: [
          {
            fullUrl: 'resource:0',
            resource: FHIR::Patient.new(
              name: [
                {
                  family: 'Rowe',
                  given: ['Corrina']
                }
              ],
              birthDate: '1971-12-06',
              resourceType: 'Patient'
            )
          },
          {
            fullUrl: 'resource:1',
            resource: FHIR::Immunization.new(
              status: 'completed',
              vaccineCode: {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/sid/cvx',
                    code: '207'
                  }
                ]
              },
              patient: {
                reference: 'resource:0'
              },
              occurrenceDateTime: '2025-02-05',
              lotNumber: '1234567',
              resourceType: 'Immunization'
            )
          }
        ],
        resourceType: 'Bundle'
      )
    end

    let(:fhir_bundle_deanne_gleichner) do
      FHIR::Bundle.new(
        type: 'collection',
        entry: [
          {
            fullUrl: 'resource:0',
            resource: FHIR::Patient.new(
              name: [
                {
                  family: 'Gleichner',
                  given: [
                    'Deanne'
                  ]
                }
              ],
              birthDate: '2007-04-11',
              resourceType: 'Patient'
            )
          },
          {
            fullUrl: 'resource:1',
            resource: FHIR::Immunization.new(
              status: 'completed',
              vaccineCode: {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/sid/cvx',
                    code: '210'
                  }
                ]
              },
              patient: {
                reference: 'resource:0'
              },
              occurrenceDateTime: '2025-02-04',
              lotNumber: '1234567',
              resourceType: 'Immunization'
            )
          }
        ],
        resourceType: 'Bundle'
      )
    end

    before do
      stub_request(:post, validation_url)
        .to_return(status: 200, body: operation_outcome_success.to_json)
    end

    it 'passes if the input is an array with a single bundle conforms to the FHIR Bundle profile' do
      fhir_bundles = [ fhir_bundle_corrina_rowe ].to_json
      result = run(test, { file_download_url: url, fhir_bundles: fhir_bundles })
      expect(result.result).to eq('pass')
    end

    it 'passes if the input is an array of multiple bundles that all conform to the FHIR Bundle profile' do
      fhir_bundles = [
        fhir_bundle_corrina_rowe,
        fhir_bundle_deanne_gleichner
    ].to_json
      result = run(test, { file_download_url: url, fhir_bundles: fhir_bundles })
      expect(result.result).to eq('pass')
    end

    it 'skips if the no FHIR bundles received' do
      result = run(test, { file_download_url: url, fhir_bundles: [].to_json })
      expect(result.result).to eq('skip')
    end
  end
end
