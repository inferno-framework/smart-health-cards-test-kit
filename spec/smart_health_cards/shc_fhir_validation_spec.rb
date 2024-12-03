RSpec.describe SmartHealthCards::SHCFHIRValidation do
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

  describe 'health_card_fhir_validation_test' do

    let(:test) { group.tests.find { |t| t.id.include?('shc_fhir_validation_test')} } 
    let(:url) { 'http://example.com/hc' }

    #TODO: update text with specific bundle type
    it 'passes if the JWS payload conforms to the FHIR Bundle profile' do 
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.hVLLjtQwEPyX5pqHk5nMI0fggoQAwcIFzcFxOhMjx45sJ2JY5d9pJ7tktLuz5BLZrq6uqu57kM5BCa33fZmmygiuWuN8uWGMQQS6aqDM9hu22xd5nkUwCijvwV96hPLnXOaoznXc-ha58m0iuK3dm-UQhwPR3MYJM8o6O76KkV03aPmHe2k0nCIQFmvUXnL1bah-ofBBUtNK-wOtC5gStglLMiINt28HXStcZYMwSlFVQEZARPZCXohhUOq7VQSw6MxgBZYhgsdDINC8wwXLO6moDD5y62aesxxRh0y-ctEiNYDTRForSWbecx_6ZsddFrMszo9XtHeLpi_kjqTANEUvKsmeKHGe-8HNZrpeoccQ88iFkBrfmXrGCFNLfZ71uovz2K2DbtU-MfachnxSJ-tUjL-JQMyVkLMDTKcpgv5BFZFZbNCiDt2v8yGQEWKw81PweSe7hSLfxhkju0SrjP80dBXaEEK-2Ra7_fMEPlxP-VYM-a0YGqm5-ufgVe_KSC2C-9VwwYrtId4vpt26VLdNY9OEFRpf8pwV8yzUME-CV4r-xNH7_whz2nRYJ1I3JnUkYJ3Hjm0OBWPHReCT4D5XDu34mNvp2fvD_k_0_QU.-jNkrXCHlq75fLCGvD8_7eF4iQ-XYQT7uZyiZ1Fqa33-ZQA1-aVEk519JZYGMDdJpO-mVqIC20Xh9sBsD8COzg'
      
      #TODO: figure out how to stub request to validator
      #stub_request(:post, "https://example.com/validatorapi/validate").
      #   with(
      #     body: "{\"cliContext\":{\"sv\":\"4.0.1\",\"doNative\":false,\"extensions\":[\"any\"],\"disableDefaultResourceFetcher\":true,\"profiles\":[\"http://hl7.org/fhir/StructureDefinition/Bundle\"]},\"filesToValidate\":[{\"fileName\":\"Bundle/.json\",\"fileContent\":\"{\\\"type\\\":\\\"collection\\\",\\\"entry\\\":[{\\\"fullUrl\\\":\\\"resource:0\\\",\\\"resource\\\":{\\\"name\\\":[{\\\"family\\\":\\\"Larson\\\",\\\"given\\\":[\\\"Rachelle\\\"]}],\\\"birthDate\\\":\\\"1961-01-29\\\",\\\"resourceType\\\":\\\"Patient\\\"}},{\\\"fullUrl\\\":\\\"resource:1\\\",\\\"resource\\\":{\\\"status\\\":\\\"completed\\\",\\\"vaccineCode\\\":{\\\"coding\\\":[{\\\"system\\\":\\\"http://hl7.org/fhir/sid/cvx\\\",\\\"code\\\":\\\"208\\\"}]},\\\"patient\\\":{\\\"reference\\\":\\\"resource:0\\\"},\\\"occurrenceDateTime\\\":\\\"2024-10-01\\\",\\\"lotNumber\\\":\\\"1234567\\\",\\\"resourceType\\\":\\\"Immunization\\\"}},{\\\"fullUrl\\\":\\\"resource:2\\\",\\\"resource\\\":{\\\"status\\\":\\\"final\\\",\\\"code\\\":{\\\"coding\\\":[{\\\"system\\\":\\\"http://loinc.org\\\",\\\"code\\\":\\\"50548-7\\\"}]},\\\"subject\\\":{\\\"reference\\\":\\\"resource:0\\\"},\\\"effectiveDateTime\\\":\\\"2024-10-15\\\",\\\"valueCodeableConcept\\\":{\\\"coding\\\":[{\\\"system\\\":\\\"http://snomed.info/sct\\\",\\\"code\\\":\\\"260385009\\\"}]},\\\"resourceType\\\":\\\"Observation\\\"}}],\\\"resourceType\\\":\\\"Bundle\\\"}\",\"fileType\":\"json\"}],\"sessionId\":null}",
      #     headers: {
      #    'Accept'=>'*/*',
      #    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      #    'Content-Type'=>'application/json',
      #    'User-Agent'=>'Faraday v1.10.3'
      #     }).
      #   to_return(status: 200, body: FHIR::OperationOutcome.new.to_json, headers: {})
      
      result = run(test, { file_download_url: url, url: url, credential_strings: credential_strings, skip_validation: true })
      expect(result.result).to eq('pass')
    end

    it 'passes if a comma-separated list of VCs all contain JWS payloads that conform to the FHIR Bundle profile' do
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.hVLLjtQwEPyX5pqHk5nMI0fggoQAwcIFzcFxOhMjx45sJ2JY5d9pJ7tktLuz5BLZrq6uqu57kM5BCa33fZmmygiuWuN8uWGMQQS6aqDM9hu22xd5nkUwCijvwV96hPLnXOaoznXc-ha58m0iuK3dm-UQhwPR3MYJM8o6O76KkV03aPmHe2k0nCIQFmvUXnL1bah-ofBBUtNK-wOtC5gStglLMiINt28HXStcZYMwSlFVQEZARPZCXohhUOq7VQSw6MxgBZYhgsdDINC8wwXLO6moDD5y62aesxxRh0y-ctEiNYDTRForSWbecx_6ZsddFrMszo9XtHeLpi_kjqTANEUvKsmeKHGe-8HNZrpeoccQ88iFkBrfmXrGCFNLfZ71uovz2K2DbtU-MfachnxSJ-tUjL-JQMyVkLMDTKcpgv5BFZFZbNCiDt2v8yGQEWKw81PweSe7hSLfxhkju0SrjP80dBXaEEK-2Ra7_fMEPlxP-VYM-a0YGqm5-ufgVe_KSC2C-9VwwYrtId4vpt26VLdNY9OEFRpf8pwV8yzUME-CV4r-xNH7_whz2nRYJ1I3JnUkYJ3Hjm0OBWPHReCT4D5XDu34mNvp2fvD_k_0_QU.-jNkrXCHlq75fLCGvD8_7eF4iQ-XYQT7uZyiZ1Fqa33-ZQA1-aVEk519JZYGMDdJpO-mVqIC20Xh9sBsD8COzg,eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.fZDBTsMwEET_ZbkmaUJatfURVT0jFbigHhxnWxs5drV2IoUq_866oUJCAt_WfjOe2SuYEECAjvEiFgvrlbTahyjqsiwhA9ecQFTruqrrzWa1zGBQIK4QxwuCeL_JAutCJylqlDbqQklqw8M85Glgm7855QfTVtt_GdN1vTOfMhrv4JiBImzRRSPtoW8-UMUU6aQNvSGFxAhYFmVRsWm6fepda_EnNihvLasSmQEb0chd2KG39pUsA4TB96RQpBXch2TgZIczKztjWQZ7EzQSY2czoEs7OXiSo4TjxEkbw1V2MqZfq-3jKi_X-a3s3fRlTvTM3TgITEn06-07_sTnCw.pYwsdxlzdXVhnPzO_YDlMXnSHHz88XA3A9bGuzutySq2v3tO5lOWsfsOQGhoWiH7LCtUNpoizX5GSi5cXVI19g'
      result = run(test, { file_download_url: url, url: url, credential_strings: credential_strings, skip_validation: true })
      expect(result.result).to eq('pass')
    end

    it 'raises an error if the JWS payload does not conform to the FHIR Bundle profile' do
      credential_strings = 'asdf'
      expect {result = run(test, { file_download_url: url, url: url, credential_strings: credential_strings, skip_validation: true })}.to raise_error()
    end

  end

end