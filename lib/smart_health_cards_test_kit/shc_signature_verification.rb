require_relative 'utils/verifier'

module SmartHealthCardsTestKit
  class SHCSignatureVerification < Inferno::Test
    include HealthCard

    id :shc_signature_verification_test
    title 'Verifiable Credential JWS payload has correct JWS signature'
    description %(
      Each public key used to verify signatures is represented as a JSON Web Key
      (see [RFC7517](https://tools.ietf.org/html/rfc7517)), with some of its properties encoded using
      base64url (see section 5 of [RFC4648](https://tools.ietf.org/html/rfc4648#section-5)):

      * SHALL have "kty": "EC", "use": "sig", and "alg": "ES256"
      * SHALL have "kid" equal to the base64url-encoded SHA-256 JWK Thumbprint of the key
      (see [RFC7638](https://tools.ietf.org/html/rfc7638))
      * SHALL have "crv": "P-256", and "x", "y" equal to the base64url-encoded values for the public Elliptic
      Curve point coordinates (see [RFC7518](https://tools.ietf.org/html/rfc7518#section-6.2))
      * SHALL NOT have the Elliptic Curve private key parameter "d"
      * If the issuer has an X.509 certificate for the public key, SHALL have "x5c" equal to an array of one
      or more base64-encoded (not base64url-encoded) DER representations of the public certificate or
      certificate chain (see [RFC7517](https://tools.ietf.org/html/rfc7517#section-4.7)). The public key
      listed in the first certificate in the "x5c" array SHALL match the public key specified by the "crv",
      "x", and "y" parameters of the same JWK entry. If the issuer has more than one certificate for the same
      public key (e.g. participation in more than one trust community), then a separate JWK entry is used for
      each certificate with all JWK parameter values identical except "x5c".

      Issuers SHALL publish their public keys as JSON Web Key Sets (see
      [RFC7517](https://tools.ietf.org/html/rfc7517#section-4.7)), available at
      <<iss value from JWS>> + /.well-known/jwks.json, with Cross-Origin Resource Sharing (CORS) enabled, using
      TLS version 1.2 following the IETF BCP 195 recommendations or TLS version 1.3 (with any configuration).

      The URL at <<iss value from JWS>> SHALL use the https scheme and SHALL NOT include a trailing /.
      For example, https://smarthealth.cards/examples/issuer is a valid iss value
      (https://smarthealth.cards/examples/issuer/ is not).
    )

    input :credential_strings

    run do
      skip_if credential_strings.blank?, 'No Verifiable Credentials received'

      credential_strings.split(',').each do |credential|

        jws = SmartHealthCardsTestKit::Utils::JWS.from_jws(credential)
        payload = payload_from_jws(jws)
        iss = payload['iss']

        assert iss.present?, 'Credential contains no `iss`'
        warning { assert iss.start_with?('https://'), "`iss` SHALL use the `https` scheme: #{iss}" }
        assert !iss.end_with?('/'), "`iss` SHALL NOT include a trailing `/`: #{iss}"

        key_set_url = "#{iss}/.well-known/jwks.json"

        get(key_set_url)

        assert_response_status(200)
        assert_valid_json(response[:body])

        cors_header = request.response_header('Control-Allow-Origin')
        warning do
          assert cors_header.present?,
                 'No CORS header received. Issuers SHALL publish their public keys with CORS enabled'
          assert cors_header.value == '*',
                 "Expected CORS header value of `*`, but actual value was `#{cors_header.value}`"
        end

        key_set = JSON.parse(response[:body])

        public_key = key_set['keys'].find { |key| key['kid'] == jws.kid }
        key_object = SmartHealthCardsTestKit::Utils::Key.from_jwk(public_key)

        assert public_key.present?, "Key set did not contain a key with a `kid` of #{jws.kid}"

        assert public_key['kty'] == 'EC', "Key had a `kty` value of `#{public_key['kty']}` instead of `EC`"
        assert public_key['use'] == 'sig', "Key had a `use` value of `#{public_key['use']}` instead of `sig`"
        assert public_key['alg'] == 'ES256', "Key had an `alg` value of `#{public_key['alg']}` instead of `ES256`"
        assert public_key['crv'] == 'P-256', "Key had a `crv` value of `#{public_key['crv']}` instead of `P-256`"
        assert !public_key.include?('d'), 'Key SHALL NOT have the private key parameter `d`'
        assert public_key['kid'] == key_object.kid,
          "'kid' SHALL be equal to the base64url-encoded SHA-256 JWK Thumbprint of the key. " \
          "Received: '#{public_key['kid']}', Expected: '#{key_object.kid}'"

        verifier = SmartHealthCardsTestKit::Utils::Verifier.new(keys: key_object, resolve_keys: false)

        begin
          assert verifier.verify(jws), 'JWS signature invalid'
        rescue StandardError => e
          assert false, "Error decoding credential: #{e.message}"
        end
      end
    end
  end
end

