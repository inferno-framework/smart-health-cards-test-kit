module SmartHealthCards
  class SHCSignatureVerification < Inferno::Test
    id :shc_signature_verification_test
    title 'Verify the correct SHC signature'
    input :credential_strings
    output :decompressed_signatures #TODO record output

    run do
      skip_if credential_strings.blank?, 'No Verifiable Credentials received'
      decompressed_signature_array = []

      credential_strings.split(',').each do |credential|
        card = HealthCards::JWS.from_jws(credential)

        #this is the signature verification test, so we're not verifying the payload, but we still need the payload to get the issuer
        decompressed_payload =
        begin
          Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(card.payload)
        rescue Zlib::DataError
          assert false, 'Payload compression error. Unable to inflate payload.'
        end

        json_payload = JSON.parse(decompressed_payload)
        iss = json_payload['iss']

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
        key_object = HealthCards::Key.from_jwk(public_key)


        assert public_key.present?, "Key set did not contain a key with a `kid` of #{jws.kid}"

        warning { assert public_key['kty'] == 'EC', "Key had a `kty` value of `#{public_key['kty']}` instead of `EC`" }
        warning do
          assert public_key['use'] == 'sig', "Key had a `use` value of `#{public_key['use']}` instead of `sig`"
        end
        warning do
          assert public_key['alg'] == 'ES256', "Key had an `alg` value of `#{public_key['alg']}` instead of `ES256`"
        end
        warning do
          assert public_key['crv'] == 'P-256', "Key had a `crv` value of `#{public_key['crv']}` instead of `P-256`"
        end
        warning { assert !public_key.include?('d'), 'Key SHALL NOT have the private key parameter `d`' }
        warning do
          assert public_key['kid'] == key_object.kid,
                 "'kid' SHALL be equal to the base64url-encoded SHA-256 JWK Thumbprint of the key. " \
                 "Received: '#{public_key['kid']}', Expected: '#{key_object.kid}'"
        end

        verifier = HealthCards::Verifier.new(keys: key_object, resolve_keys: false)

        begin
          assert verifier.verify(jws), 'JWS signature invalid'
        rescue StandardError => e
          assert false, "Error decoding credential: #{e.message}"
        end
      end
    end
  end
end

