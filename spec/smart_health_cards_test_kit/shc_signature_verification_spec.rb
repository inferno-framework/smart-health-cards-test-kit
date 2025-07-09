RSpec.describe SmartHealthCardsTestKit::SHCSignatureVerification do
  let(:suite_id) { 'smart_health_cards' }
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

  describe 'health_card_signature_test' do
    let(:test) { find_test suite, 'shc_signature_verification_test' }
    let(:url) { 'http://example.com/hc' }
    let(:jwks_url) { 'http://localhost:3000/.well-known/jwks.json' }

    it 'passes if the JWS signature is correct' do
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6Ik84MGVzNUxhdGY3S0p5YW1zSndmZ210LS0tMEI1Ym55ZDZxeHVJOTloS1EifQ.fZDNTsMwEITfZbkmaZxEgviIeAAkfg5FPWycbWPkn8p2KpUq786agEBI4NvaM59n9gI6RpAwpXSUm43xCs3kY5JtXddQgBv2IMV12_Q3XVN3BZwUyAuk85FAvnzYIvuixZAmQpOmSmEY49U6lHlgzN865U96FP2_Gm3t7PQbJu0d7ApQgUZySaN5mIdXUilH2k86PFOIWSOhq-pKMDTf3s5uNPQdG5Q3hl1ZWQCDwpm7MGE25ikYFgSKfg6KZF7B15ABDi2tWrTasA22miy6DDroE7m8lK0PqEeE3cJZB81l7jDlf0Xf9qUQpWh-YB_XTPfcjqPAkk2_3j4LLHzeAQ.ynqPcijxmj63lYd2ECJvo6iLWqICu-QC-IG5MmbC0Q1M61AH-WYlKptzd9gWGnLEpbiBqohvKoBfsJnsZ0kWTQ'

      stub_request(:get, jwks_url).
         to_return(status: 200, body: jwks.to_json, headers: {})

      result = run(test, { file_download_url: url, credential_strings: credential_strings })
      expect(result.result).to eq('pass')
    end

    it 'passes if a comma-separated list of jws all contain valid signatures' do
      credential_strings = 'eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6Ik84MGVzNUxhdGY3S0p5YW1zSndmZ210LS0tMEI1Ym55ZDZxeHVJOTloS1EifQ.fZDNTsMwEITfZbkmaZxEgviIeAAkfg5FPWycbWPkn8p2KpUq786agEBI4NvaM59n9gI6RpAwpXSUm43xCs3kY5JtXddQgBv2IMV12_Q3XVN3BZwUyAuk85FAvnzYIvuixZAmQpOmSmEY49U6lHlgzN865U96FP2_Gm3t7PQbJu0d7ApQgUZySaN5mIdXUilH2k86PFOIWSOhq-pKMDTf3s5uNPQdG5Q3hl1ZWQCDwpm7MGE25ikYFgSKfg6KZF7B15ABDi2tWrTasA22miy6DDroE7m8lK0PqEeE3cJZB81l7jDlf0Xf9qUQpWh-YB_XTPfcjqPAkk2_3j4LLHzeAQ.ynqPcijxmj63lYd2ECJvo6iLWqICu-QC-IG5MmbC0Q1M61AH-WYlKptzd9gWGnLEpbiBqohvKoBfsJnsZ0kWTQ,eyJ6aXAiOiJERUYiLCJhbGciOiJFUzI1NiIsImtpZCI6Ik84MGVzNUxhdGY3S0p5YW1zSndmZ210LS0tMEI1Ym55ZDZxeHVJOTloS1EifQ.fZDNTsMwEITfZbkmaZxEgviIeAAkfg5FPWycbWPkn8p2KpUq786agEBI4NvaM59n9gI6RpAwpXSUm43xCs3kY5JtXddQgBv2IMV12_Q3XVN3BZwUyAuk85FAvnzYIvuixZAmQpOmSmEY49U6lHlgzN865U96FP2_Gm3t7PQbJu0d7ApQgUZySaN5mIdXUilH2k86PFOIWSOhq-pKMDTf3s5uNPQdG5Q3hl1ZWQCDwpm7MGE25ikYFgSKfg6KZF7B15ABDi2tWrTasA22miy6DDroE7m8lK0PqEeE3cJZB81l7jDlf0Xf9qUQpWh-YB_XTPfcjqPAkk2_3j4LLHzeAQ.ynqPcijxmj63lYd2ECJvo6iLWqICu-QC-IG5MmbC0Q1M61AH-WYlKptzd9gWGnLEpbiBqohvKoBfsJnsZ0kWTQ'

      stub_request(:get, jwks_url).
         to_return(status: 200, body: jwks.to_json, headers: {})

      result = run(test, { file_download_url: url, credential_strings: credential_strings })
      expect(result.result).to eq('pass')
    end

    it 'raises an error if the vc is not a valid jws, and therefore does not contain a valid signature' do
      credential_strings = 'asdf'
      expect {result = run(test, { file_download_url: url, credential_strings: credential_strings })}.to raise_error()
    end
  end
end
