require_relative 'version'

module SmartHealthCardsTestKit
  class Metadata < Inferno::TestKit
    id :smart_health_cards
    title 'SMART Health Cards Test Kit'
    description <<~DESCRIPTION
      The SMART Health Cards Test Kit provides an
      executable set of tests for the [SMART Health Cards Framework v1.4.0](https://spec.smarthealth.cards/).
      This test kit simulates downloading and validating a SMART Health Card.
      <!-- break -->

      This test kit is [open source](https://github.com/inferno-framework/smart-health-cards-test-kit#license)
      and freely available for use or adoption by the health IT community including EHR vendors, health app
      developers, and testing labs. It is built using the [Inferno Framework](https://inferno-framework.github.io/inferno-core/).
      The Inferno Framework is designed for reuse and aims to make it easier to build test kits for any
      FHIR-based data exchange.

      ## Status

      These tests are intended to allow server implementers to perform checks of their server against SMART Health Cards Framework requrirements.

      The test kit currently tests the following requirements:
      - Download and validate a health card [via File Download](https://spec.smarthealth.cards/#via-file-download)
      - Download and validate a health card [via FHIR $health-cards-issue Operation](https://spec.smarthealth.cards/#via-fhir-health-cards-issue-operation)
      - Download and validate a health card [via QR Code](https://spec.smarthealth.cards/#via-qr-print-or-scan)

      The test kit does **NOT** test this requirement:
      - Download and validate a health card [via Deep Link](https://spec.smarthealth.cards/#via-deep-link)

      See the test descriptions within the test kit for detail on the specific validations performed as part of testing these requirements.

      ## Repository

      The SMART Health Cards Test Kit GitHub repository can be [found here](https://github.com/inferno-framework/smart-health-cards-test-kit).

      ## Providing Feedback and Reporting Issues

      We welcome feedback on the tests, including but not limited to the following areas:

      - Validation logic, such as potential bugs, lax checks, and unexpected failures.
      - Requirements coverage, such as requirements that have been missed, tests that necessitate features that the IG does not require, or other issues with the interpretation of the IG's requirements.
      - User experience, such as confusing or missing information in the test UI.

      Please report any issues with this set of tests in the [issues section](https://github.com/inferno-framework/smart-health-cards-test-kit/issues) of the repository.
    DESCRIPTION
    suite_ids [:smart_health_cards]
    tags ['SMART Health Cards']
    last_updated LAST_UPDATED
    version VERSION
    maturity 'Low'
    authors ['Yunwei Wang']
    repo 'https://github.com/inferno-framework/smart-health-cards-test-kit'
  end
end
