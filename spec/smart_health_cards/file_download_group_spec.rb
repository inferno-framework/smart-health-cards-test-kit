RSpec.describe SmartHealthCards::FileDownloadGroup do
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

  describe 'health_card_download_test' do
    let(:test) { group.tests.first }
    let(:url) { 'http://example.com/hc' }

    it 'passes if valid json is downloaded' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 200, body: { abc: 'def' }.to_json)

      #binding.pry

      result = run(test, { file_download_url: url, url: url })

      expect(stubbed_request).to have_been_made.once
      expect(result.result).to eq('pass')
    end

    it 'fails if a non-200 status code is received' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 500, body: { abc: 'def' }.to_json)

        result = run(test, { file_download_url: url, url: url })

      expect(stubbed_request).to have_been_made.once
      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/200/)
    end

    it 'fails if a non-JSON payload is received' do
      stubbed_request =
        stub_request(:get, url)
          .to_return(status: 200, body: 'def')

      result = run(test, { file_download_url: url, url: url })

      expect(stubbed_request).to have_been_made.once
      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/JSON/)
    end
  end

  describe 'health_card_payload_test' do
    let(:test) { group.tests[4] }
    let(:url) { 'http://example.com/hc' }

    #todo: for a more thorough test, consider setting credential_strings to a string of comma-separated of several VCs instead of a single VC string 
    credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.hVLLjtQwEPyX5pqHk5nMI0fggoQAwcIFzcFxOhMjx45sJ2JY5d9pJ7tktLuz5BLZrq6uqu57kM5BCa33fZmmygiuWuN8uWGMQQS6aqDM9hu22xd5nkUwCijvwV96hPLnXOaoznXc-ha58m0iuK3dm-UQhwPR3MYJM8o6O76KkV03aPmHe2k0nCIQFmvUXnL1bah-ofBBUtNK-wOtC5gStglLMiINt28HXStcZYMwSlFVQEZARPZCXohhUOq7VQSw6MxgBZYhgsdDINC8wwXLO6moDD5y62aesxxRh0y-ctEiNYDTRForSWbecx_6ZsddFrMszo9XtHeLpi_kjqTANEUvKsmeKHGe-8HNZrpeoccQ88iFkBrfmXrGCFNLfZ71uovz2K2DbtU-MfachnxSJ-tUjL-JQMyVkLMDTKcpgv5BFZFZbNCiDt2v8yGQEWKw81PweSe7hSLfxhkju0SrjP80dBXaEEK-2Ra7_fMEPlxP-VYM-a0YGqm5-ufgVe_KSC2C-9VwwYrtId4vpt26VLdNY9OEFRpf8pwV8yzUME-CV4r-xNH7_whz2nRYJ1I3JnUkYJ3Hjm0OBWPHReCT4D5XDu34mNvp2fvD_k_0_QU.-jNkrXCHlq75fLCGvD8_7eF4iQ-XYQT7uZyiZ1Fqa33-ZQA1-aVEk519JZYGMDdJpO-mVqIC20Xh9sBsD8COzg'

    it 'passes if JWS payload is structured correctly' do
      
      result = run(test, { file_download_url: url, url: url, credential_strings: credential_strings })

      payloads = JSON.parse(result.output_json)
      payloads.each do |payload|
        value = JSON.parse(payload['value'])

        expect(value['nbf']).to be_a_kind_of(Integer)

        #TODO: work in progress - more tests will go here
        
        #binding.pry

      end
      
    end

    
    
    


  end



  # describe 'vci-file-02' do
  #   let(:test) { group.tests[1] }
  #   let(:url) { 'http://example.com/hc' }

  #   it 'passes if the response has the correct Content-Type header' do
  #     request_repo.create(
  #       status: 200,
  #       response_headers: [{ name: 'content-type', value: 'application/smart-health-card' }],
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('pass')
  #   end

  #   it 'skips if the vci_file_download request has not been made' do
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #     expect(result.result_message).to match(/vci_file_download/)
  #   end

  #   it 'skips if a non-200 response was received' do
  #     request_repo.create(
  #       status: 500,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #   end

  #   it 'fails if the response has an incorrect Content-Type header' do
  #     request_repo.create(
  #       status: 200,
  #       response_headers: [{ name: 'content-type', value: 'application/json' }],
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/Content-Type/)
  #   end

  #   it 'fails if the response has no Content-Type header' do
  #     request_repo.create(
  #       status: 200,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/did not include/)
  #   end
  # end

  # describe 'vci-file-03' do
  #   let(:test) { group.tests[2] }
  #   let(:url) { 'http://example.com/hc' }

  #   it 'passes if the download url ends in .smart-health-card' do
  #     request_repo.create(
  #       status: 200,
  #       url: 'http://example.com/hc.smart-health-card',
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('pass')
  #   end

  #   it 'skips if the vci_file_download request has not been made' do
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #     expect(result.result_message).to match(/vci_file_download/)
  #   end

  #   it 'skips if a non-200 response was received' do
  #     request_repo.create(
  #       status: 500,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #   end

  #   context 'with a url that does not end in .smart-health-card' do
  #     let(:url) { 'http://example.com/hc' }

  #     it 'passes if the response contains a Content-Disposition header with a .smart-health-card extension' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         response_headers: [{ name: 'content-disposition', value: 'attachment; filename="hc.smart-health-card"' }],
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )

  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('pass')
  #     end

  #     it 'fails if no Content-Disposition header is received' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )
  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('fail')
  #     end

  #     it 'fails if Content-Disposition header does not indicate the file should be downloaded' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         response_headers: [{ name: 'content-disposition', value: 'inline' }],
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )

  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('fail')
  #       expect(result.result_message).to match(/should be downloaded/)
  #     end

  #     it 'fails if Content-Disposition header does not indicate a .smart-health-card extension' do
  #       request_repo.create(
  #         status: 200,
  #         url: url,
  #         response_headers: [{ name: 'content-disposition', value: 'attachment; filename="hc.health-card"' }],
  #         name: :vci_file_download,
  #         verb: 'get',
  #         direction: 'outgoing',
  #         test_session_id: test_session.id,
  #         result_id: repo_create(:result).id
  #       )
  #       result = run(test, { file_download_url: url })

  #       expect(result.result).to eq('fail')
  #       expect(result.result_message).to match(/extension/)
  #     end
  #   end
  # end

  # describe 'vci-file-04' do
  #   let(:test) { group.tests[3] }
  #   let(:url) { 'http://example.com/hc' }

  #   it 'passes if the response contains an array of VC strings' do
  #     request_repo.create(
  #       status: 200,
  #       response_body: { 'verifiableCredential' => ['abc'] }.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('pass')
  #   end

  #   it 'skips if the vci_file_download request has not been made' do
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #     expect(result.result_message).to match(/vci_file_download/)
  #   end

  #   it 'skips if a non-200 response was received' do
  #     request_repo.create(
  #       status: 500,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )
  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('skip')
  #   end

  #   it "fails if the body does not contain a 'verifiableCredential' field" do
  #     request_repo.create(
  #       status: 200,
  #       response_body: {}.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/does not contain/)
  #   end

  #   it "fails if the 'verifiableCredential' field does not contain an array" do
  #     request_repo.create(
  #       status: 200,
  #       response_body: { 'verifiableCredential' => 'abc' }.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/must contain an Array/)
  #   end

  #   it "fails if the 'verifiableCredential' field contains an empty array" do
  #     request_repo.create(
  #       status: 200,
  #       response_body: { 'verifiableCredential' => [] }.to_json,
  #       name: :vci_file_download,
  #       verb: 'get',
  #       direction: 'outgoing',
  #       test_session_id: test_session.id,
  #       result_id: repo_create(:result).id,
  #       url: 'http://example.com/hc'
  #     )

  #     result = run(test, { file_download_url: url })

  #     expect(result.result).to eq('fail')
  #     expect(result.result_message).to match(/at least one/)
  #   end
  # end
end
