RSpec.describe SmartHealthCardsTestKit::FileDownloadGroup do
  let(:suite_id) { 'smart_health_cards' }
  let(:request_repo) { Inferno::Repositories::Requests.new }

  describe 'health_card_download_test' do
    let(:test) { find_test suite, 'health_card_download_test' }
    let(:url) { 'http://example.com/hc' }

    it 'passes if valid json is downloaded' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 200, body: { abc: 'def' }.to_json)

      result = run(test, { file_download_url: url })

      expect(stubbed_request).to have_been_made.once
      expect(result.result).to eq('pass')
    end

    it 'fails if a non-200 status code is received' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 500, body: { abc: 'def' }.to_json)

        result = run(test, { file_download_url: url })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/200/)
    end

    it 'fails if a non-JSON payload is received' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 200, body: 'def')

      result = run(test, { file_download_url: url })

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/JSON/)
    end
  end
end
