module SmartHealthCardsTestKit
  class SHCFHIRValidation < Inferno::Test
    include HealthCard

    id :shc_fhir_validation_test
    title 'SMART Health Card payload conforms to the FHIR Bundle Profile'
    description %(
      SMART Health Card payload SHALL be a valid FHIR Bundle resource
    )

    run do
      fhir_bundles = scratch[:bundles]
      skip_if fhir_bundles.blank?, 'No FHIR bundles received'
      fhir_bundles.each { |bundle| assert_valid_resource(resource: bundle)}
    end
  end
end