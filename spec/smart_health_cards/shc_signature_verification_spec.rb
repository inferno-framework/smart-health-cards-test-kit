RSpec.describe SmartHealthCards::SHCSignatureVerification do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_health_cards_test_suite') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:runner) { Inferno::TestRunner.new(test_session: test_session, test_run: test_run) }
  let(:test_session) do
    Inferno::Repositories::TestSessions.new.create(test_suite_id: suite.id)
  end
  let(:request_repo) { Inferno::Repositories::Requests.new }
  let(:group) { suite.groups.first }
  let(:jwks) do
    {
      keys:[
        {
          x: 'fDRTYfppp33ft0_mLs_9yHxqjhjDP0D1eaBMYDGJOv8',
          y: 'nCihH4WsXy1VjJ87KWzqz2lBywYEMzubarKZGs-r99w',
          kty: 'EC',
          crv: 'P-256',
          kid: 'O80es5Latf7KJyamsJwfgmt---0B5bnyd6qxuI99hKQ',
          use: 'sig',
          alg: 'ES256'
        }
      ]
    }
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(test_session_id: test_session.id, name: name, value: value, type: 'text')
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  describe 'health_card_signature_test' do
    let(:test) { group.tests.find { |t| t.id.include?('shc_signature_verification_test')} }
    let(:url) { 'http://example.com/hc' }

    it 'passes if the JWS signature is correct' do
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6Ik84MGVzNUxhdGY3S0p5YW1zSndmZ210LS0tMEI1Ym55ZDZxeHVJOTloS1EifQ.fZDNTsMwEITfZbkmaZxEgviIeAAkfg5FPWycbWPkn8p2KpUq786agEBI4NvaM59n9gI6RpAwpXSUm43xCs3kY5JtXddQgBv2IMV12_Q3XVN3BZwUyAuk85FAvnzYIvuixZAmQpOmSmEY49U6lHlgzN865U96FP2_Gm3t7PQbJu0d7ApQgUZySaN5mIdXUilH2k86PFOIWSOhq-pKMDTf3s5uNPQdG5Q3hl1ZWQCDwpm7MGE25ikYFgSKfg6KZF7B15ABDi2tWrTasA22miy6DDroE7m8lK0PqEeE3cJZB81l7jDlf0Xf9qUQpWh-YB_XTPfcjqPAkk2_3j4LLHzeAQ.ynqPcijxmj63lYd2ECJvo6iLWqICu-QC-IG5MmbC0Q1M61AH-WYlKptzd9gWGnLEpbiBqohvKoBfsJnsZ0kWTQ'

      stub_request(:get, "http://localhost:3000/.well-known/jwks.json").
         to_return(status: 200, body: jwks.to_json, headers: {})

      result = run(test, { file_download_url: url, url: url, credential_strings: credential_strings })

      expect(result.result).to eq('pass')
    end

  end
end