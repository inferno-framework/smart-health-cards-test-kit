RSpec.describe SmartHealthCardsTestKit::SHCPayloadVerification do
  let(:suite_id) { 'smart_health_cards' }

  describe 'health_card_payload_test' do
    let(:test) { find_test suite, 'shc_payload_verification_test' }
    let(:url) { 'http://example.com/hc' }

    it 'passes if the JWS payload was compressed with the deflate algorithm' do
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.hVLLjtQwEPyX5pqHk5nMI0fggoQAwcIFzcFxOhMjx45sJ2JY5d9pJ7tktLuz5BLZrq6uqu57kM5BCa33fZmmygiuWuN8uWGMQQS6aqDM9hu22xd5nkUwCijvwV96hPLnXOaoznXc-ha58m0iuK3dm-UQhwPR3MYJM8o6O76KkV03aPmHe2k0nCIQFmvUXnL1bah-ofBBUtNK-wOtC5gStglLMiINt28HXStcZYMwSlFVQEZARPZCXohhUOq7VQSw6MxgBZYhgsdDINC8wwXLO6moDD5y62aesxxRh0y-ctEiNYDTRForSWbecx_6ZsddFrMszo9XtHeLpi_kjqTANEUvKsmeKHGe-8HNZrpeoccQ88iFkBrfmXrGCFNLfZ71uovz2K2DbtU-MfachnxSJ-tUjL-JQMyVkLMDTKcpgv5BFZFZbNCiDt2v8yGQEWKw81PweSe7hSLfxhkju0SrjP80dBXaEEK-2Ra7_fMEPlxP-VYM-a0YGqm5-ufgVe_KSC2C-9VwwYrtId4vpt26VLdNY9OEFRpf8pwV8yzUME-CV4r-xNH7_whz2nRYJ1I3JnUkYJ3Hjm0OBWPHReCT4D5XDu34mNvp2fvD_k_0_QU.-jNkrXCHlq75fLCGvD8_7eF4iQ-XYQT7uZyiZ1Fqa33-ZQA1-aVEk519JZYGMDdJpO-mVqIC20Xh9sBsD8COzg'
      result = run(test, { file_download_url: url, credential_strings: credential_strings })
      expect(result.result).to eq('pass')

      payloads = JSON.parse(result.output_json)
      expect(payloads).to be_a_kind_of(Array)
    end

    it 'passes if a comma-separated list of VCs all contain JWS payloads that were compressed with the deflate algorithm' do
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.hVLLjtQwEPyX5pqHk5nMI0fggoQAwcIFzcFxOhMjx45sJ2JY5d9pJ7tktLuz5BLZrq6uqu57kM5BCa33fZmmygiuWuN8uWGMQQS6aqDM9hu22xd5nkUwCijvwV96hPLnXOaoznXc-ha58m0iuK3dm-UQhwPR3MYJM8o6O76KkV03aPmHe2k0nCIQFmvUXnL1bah-ofBBUtNK-wOtC5gStglLMiINt28HXStcZYMwSlFVQEZARPZCXohhUOq7VQSw6MxgBZYhgsdDINC8wwXLO6moDD5y62aesxxRh0y-ctEiNYDTRForSWbecx_6ZsddFrMszo9XtHeLpi_kjqTANEUvKsmeKHGe-8HNZrpeoccQ88iFkBrfmXrGCFNLfZ71uovz2K2DbtU-MfachnxSJ-tUjL-JQMyVkLMDTKcpgv5BFZFZbNCiDt2v8yGQEWKw81PweSe7hSLfxhkju0SrjP80dBXaEEK-2Ra7_fMEPlxP-VYM-a0YGqm5-ufgVe_KSC2C-9VwwYrtId4vpt26VLdNY9OEFRpf8pwV8yzUME-CV4r-xNH7_whz2nRYJ1I3JnUkYJ3Hjm0OBWPHReCT4D5XDu34mNvp2fvD_k_0_QU.-jNkrXCHlq75fLCGvD8_7eF4iQ-XYQT7uZyiZ1Fqa33-ZQA1-aVEk519JZYGMDdJpO-mVqIC20Xh9sBsD8COzg,eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6IjRIVWIyYXJ2aFRTWHNzRW9NczJHNVRvRHBzWXZzajdoNXdUXzN6TkV0dWcifQ.fZDBTsMwEET_ZbkmaUJatfURVT0jFbigHhxnWxs5drV2IoUq_866oUJCAt_WfjOe2SuYEECAjvEiFgvrlbTahyjqsiwhA9ecQFTruqrrzWa1zGBQIK4QxwuCeL_JAutCJylqlDbqQklqw8M85Glgm7855QfTVtt_GdN1vTOfMhrv4JiBImzRRSPtoW8-UMUU6aQNvSGFxAhYFmVRsWm6fepda_EnNihvLasSmQEb0chd2KG39pUsA4TB96RQpBXch2TgZIczKztjWQZ7EzQSY2czoEs7OXiSo4TjxEkbw1V2MqZfq-3jKi_X-a3s3fRlTvTM3TgITEn06-07_sTnCw.pYwsdxlzdXVhnPzO_YDlMXnSHHz88XA3A9bGuzutySq2v3tO5lOWsfsOQGhoWiH7LCtUNpoizX5GSi5cXVI19g'
      result = run(test, { file_download_url: url, credential_strings: credential_strings })
      expect(result.result).to eq('pass')
    end

    it 'raises an error if the JWS payload was not compressed with the deflate algorithm' do
      credential_strings = 'asdf'
      expect {result = run(test, { file_download_url: url, credential_strings: credential_strings })}.to raise_error()
    end
  end
end
