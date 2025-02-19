module SmartHealthCardsTestKit
  class SHCFHIRValidation < Inferno::Test
    include HealthCard

    id :shc_fhir_validation_test
    title 'SMART Health Card payload conforms to the FHIR Bundle Profile'
    description %(
      SMART Health Card payload SHALL be a valid FHIR Bundle resource
    )
    input :fhir_bundles

    run do
      
      #skip_if fhir_bundles.blank?, 'No FHIR bundles received'
      jsonArray = JSON.parse(fhir_bundles)
      jsonArray.each { |json| assert_valid_resource(resource: FHIR::Bundle.new(json)) }
      #fhir_bundles.each { |bundle| assert_valid_resource(resource: bundle) }

    end
  end
end