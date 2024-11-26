module SmartHealthCards
  class SHCFHIRValidation < Inferno::Test
    id :shc_fhir_validation_test
    title 'Smart Health Card payloads conform to the correct Bundle Profiles' #TODO: update title with specific bundle type
    input :credential_strings
    output :fhir_bundles

    run do

      skip_if credential_strings.blank?, 'No Verifiable Credentials received'

      credential_strings.split(',').each do |credential|
        raw_payload = HealthCards::JWS.from_jws(credential).payload
        assert raw_payload&.length&.positive?, 'No payload found'

        decompressed_payload =
          begin
            Zlib::Inflate.new(-Zlib::MAX_WBITS).inflate(raw_payload)
          rescue Zlib::DataError
            assert false, 'Payload compression error. Unable to inflate payload.'
          end

        payload = JSON.parse(decompressed_payload)
        vc = payload['vc']
        assert vc.is_a?(Hash), "Expected 'vc' claim to be a JSON object, but found #{vc.class}"

        subject = vc['credentialSubject']
        assert subject.is_a?(Hash), "Expected 'vc.credentialSubject' to be a JSON object, but found #{subject.class}"

        raw_bundle = subject['fhirBundle']
        assert raw_bundle.is_a?(Hash), "Expected 'vc.fhirBundle' to be a JSON object, but found #{raw_bundle.class}"

        bundle = FHIR::Bundle.new(raw_bundle)

        #binding.pry

        #TODO: need url for SHC bundle (existing url was copied from vaccination test kit)
        warning do
          assert_valid_resource(
            resource: bundle,
            profile_url: 'http://hl7.org/fhir/uv/smarthealthcards-vaccination/StructureDefinition/vaccination-credential-bundle-dm'
          )
        end

      end
      #TODO: populate output variable fhir_bundles
    end
  end
end