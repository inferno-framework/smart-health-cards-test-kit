require 'health_cards'
module SmartHealthCards
  class SHCHeaderVerification < Inferno::Test
    id :shc_header_verification_test
    title 'Verify the correct SHC headers'
    description %(
      Issuers SHALL ensure that the following constraints apply at the time of issuance:

      * JWS Header
        * header includes `alg`: "ES256"
        * header includes `zip`: "DEF"
        * header includes `kid` equal to the base64url-encoded (see section 5 of [RFC4648]
          (https://tools.ietf.org/html/rfc4648#section-5)) SHA-256 JWK Thumbprint of the key
          (see [RFC7638](https://tools.ietf.org/html/rfc7638))
    )
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