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
      hash_array = eval(fhir_bundles)
      hash_array.each { |hash| assert_valid_resource(resource: FHIR::Bundle.new(hash)) }
    end
  end
end