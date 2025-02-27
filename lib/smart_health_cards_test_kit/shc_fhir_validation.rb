module SmartHealthCardsTestKit
  class SHCFHIRValidation < Inferno::Test
    include HealthCard

    id :shc_fhir_validation_test
    title 'SMART Health Card payload conforms to the FHIR Bundle Profile'
    description %(
      SMART Health Card payload SHALL be a valid FHIR Bundle resource
    )
    input :credential_strings
    output :fhir_bundles

    run do

      skip_if credential_strings.blank?, 'No Verifiable Credentials received'
      bundle_array = []

      credential_strings.split(',').each do |credential|
        jws = SmartHealthCardsTestKit::Utils::JWS.from_jws(credential)
        payload = payload_from_jws(jws)

        vc = payload['vc']
        assert vc.is_a?(Hash), "Expected 'vc' claim to be a JSON object, but found #{vc.class}"

        subject = vc['credentialSubject']
        assert subject.is_a?(Hash), "Expected 'vc.credentialSubject' to be a JSON object, but found #{subject.class}"

        raw_bundle = subject['fhirBundle']
        assert raw_bundle.is_a?(Hash), "Expected 'vc.fhirBundle' to be a JSON object, but found #{raw_bundle.class}"

        bundle = FHIR::Bundle.new(raw_bundle)
        assert_valid_resource(resource: bundle)
        bundle_array.append(bundle)

      end
      output fhir_bundles: bundle_array
    end
  end
end