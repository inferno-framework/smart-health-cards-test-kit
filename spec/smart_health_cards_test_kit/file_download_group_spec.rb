RSpec.describe SmartHealthCardsTestKit::FileDownloadGroup do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_health_cards') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:runner) { Inferno::TestRunner.new(test_session: test_session, test_run: test_run) }
  let(:test_session) do
    Inferno::Repositories::TestSessions.new.create(test_suite_id: suite.id)
  end
  let(:request_repo) { Inferno::Repositories::Requests.new }
  let(:group) { suite.groups.find { |g| g.id.include?('shc_file_download_group')} }

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(test_session_id: test_session.id, name: name, value: value, type: 'text')
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  describe 'health_card_download_test' do
    let(:test) { group.tests.find { |t| t.id.include?('health_card_download_test')} }
    let(:url) { 'http://example.com/hc' }

    it 'passes if valid json is downloaded' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 200, body: { abc: 'def' }.to_json)

      result = run(test, { file_download_url: url, url: url })

      expect(stubbed_request).to have_been_made.once
      expect(result.result).to eq('pass')
    end

    it 'fails if a non-200 status code is received' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 500, body: { abc: 'def' }.to_json)

        result = run(test, { file_download_url: url, url: url })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/200/)
    end

    it 'fails if a non-JSON payload is received' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 200, body: 'def')

      result = run(test, { file_download_url: url, url: url })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/JSON/)
    end
  end
end
