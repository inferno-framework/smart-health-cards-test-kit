RSpec.describe SmartHealthCardsTestKit::SHCFHIRValidation do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_health_cards') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:runner) { Inferno::TestRunner.new(test_session: test_session, test_run: test_run) }
  let(:test_session) do
    Inferno::Repositories::TestSessions.new.create(test_suite_id: suite.id)
  end
  let(:request_repo) { Inferno::Repositories::Requests.new }
  let(:group) { suite.groups.first }

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(test_session_id: test_session.id, name: name, value: value, type: 'text')
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  describe 'health_card_fhir_validation_test' do

    let(:test) { group.tests.find { |t| t.id.include?('shc_fhir_validation_test')} }
    let(:url) { 'http://example.com/hc' }
    let(:operation_outcome_success) do
      {
        outcomes: [{
          issues: []
        }],
        sessionId: 'b8cf5547-1dc7-4714-a797-dc2347b93fe2'
      }
    end
    let(:fhir_bundle_corrina_rowe) do
      FHIR::Bundle.new(
        type: 'collection',
        entry: [
          {
            fullUrl: 'resource:0',
            resource: {
              name: [
                {
                  family: 'Rowe',
                  given: ['Corrina']
                }
              ],
              birthDate: '1971-12-06',
              resourceType: 'Patient'
            }
          },
          {
            fullUrl: 'resource:1',
            resource: {
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
            }
          }
        ],
        resourceType: 'Bundle'
      )
    end

    let (:fhir_bundle_deanne_gleichner) do
      FHIR::Bundle.new(
        type: 'collection',
        entry: [
          {
            fullUrl: 'resource:0',
            resource: {
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
            }
          },
          {
            fullUrl: 'resource:1',
            resource: {
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
            }
          }
        ],
        resourceType: 'Bundle'
      )
    end

    let(:test_scratch) { {} }

    before do
      stub_request(:post, "https://example.com/validatorapi/validate")
        .to_return(status: 200, body: operation_outcome_success.to_json)

      allow_any_instance_of(test)
        .to receive(:scratch).and_return(test_scratch)
      end

    it 'passes if the input is an array with a single bundle conforms to the FHIR Bundle profile' do
      test_scratch[:bundles] = [ fhir_bundle_corrina_rowe ]
      result = run(test, { file_download_url: url, url: url})
      expect(result.result).to eq('pass')
    end

    it 'passes if the input is an array of multiple bundles that all conform to the FHIR Bundle profile' do
      test_scratch[:bundles] = [
        fhir_bundle_corrina_rowe,
        fhir_bundle_deanne_gleichner
      ]
      result = run(test, { file_download_url: url, url: url})
      expect(result.result).to eq('pass')
    end

    it 'skips if the no FHIR bundles received' do
      test_scratch[:bundles] = []
      result = run(test, { file_download_url: url, url: url})
      expect(result.result).to eq('skip')
    end

  end
end