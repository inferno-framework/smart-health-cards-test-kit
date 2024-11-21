RSpec.describe SmartHealthCards::SHCSignatureVerification do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_health_cards_test_suite') }
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

  describe 'health_card_signature_test' do
    let(:test) { group.tests[4] }
    let(:url) { 'http://example.com/hc' }
    
    it 'passes if the JWS signature is correct' do
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.hVLLjtQwEPyX5pqHk5nMI0fggoQAwcIFzcFxOhMjx45sJ2JY5d9pJ7tktLuz5BLZrq6uqu57kM5BCa33fZmmygiuWuN8uWGMQQS6aqDM9hu22xd5nkUwCijvwV96hPLnXOaoznXc-ha58m0iuK3dm-UQhwPR3MYJM8o6O76KkV03aPmHe2k0nCIQFmvUXnL1bah-ofBBUtNK-wOtC5gStglLMiINt28HXStcZYMwSlFVQEZARPZCXohhUOq7VQSw6MxgBZYhgsdDINC8wwXLO6moDD5y62aesxxRh0y-ctEiNYDTRForSWbecx_6ZsddFrMszo9XtHeLpi_kjqTANEUvKsmeKHGe-8HNZrpeoccQ88iFkBrfmXrGCFNLfZ71uovz2K2DbtU-MfachnxSJ-tUjL-JQMyVkLMDTKcpgv5BFZFZbNCiDt2v8yGQEWKw81PweSe7hSLfxhkju0SrjP80dBXaEEK-2Ra7_fMEPlxP-VYM-a0YGqm5-ufgVe_KSC2C-9VwwYrtId4vpt26VLdNY9OEFRpf8pwV8yzUME-CV4r-xNH7_whz2nRYJ1I3JnUkYJ3Hjm0OBWPHReCT4D5XDu34mNvp2fvD_k_0_QU.-jNkrXCHlq75fLCGvD8_7eF4iQ-XYQT7uZyiZ1Fqa33-ZQA1-aVEk519JZYGMDdJpO-mVqIC20Xh9sBsD8COzg'
      
      stub_request(:get, "http://localhost:3000/.well-known/jwks.json").
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Faraday v1.10.3'
           }).
         to_return(status: 200, body: "", headers: {})
      
      result = run(test, { file_download_url: url, url: url, credential_strings: credential_strings })
      expect(result.result).to eq('pass')
    end

  end
end