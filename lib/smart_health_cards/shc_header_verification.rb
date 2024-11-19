require 'health_cards'
module SmartHealthCards
  class SHCHeaderVerification < Inferno::Test
    id :shc_header_verification_test
    title 'Verify the correct SHC headers'
    input :credential_strings
    output :headers

    run do
      skip_if credential_strings.blank?, 'No Verifiable Credentials received'
      header_array = [];
      credential_strings.split(',').each do |credential|
        header = HealthCards::JWS.from_jws(credential).header
        header_array.append(header)
        assert header['zip'] == 'DEF', "Expected 'zip' header to equal 'DEF', but found '#{header['zip']}'"
        assert header['alg'] == 'ES256', "Expected 'alg' header to equal 'ES256', but found '#{header['alg']}'"
        assert header['kid'].present?, "No 'kid' header was present"
      rescue StandardError => e
        assert false, "Error decoding credential: #{e.message}"
      end
      output headers: header_array
    end
  end
end