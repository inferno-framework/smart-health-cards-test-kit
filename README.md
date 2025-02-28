# Inferno Smart Health Card Test Kit

This is an [Inferno](https://inferno-framework.github.io/) test kit
for the SMART Health Cards Framework [v1.4.0](https://spec.smarthealth.cards/).

The test kit currently tests the following requirements:
- Download and validate a health card [via File Download](https://spec.smarthealth.cards/#via-file-download)
- Download and validate a health card [via FHIR $health-cards-issue Operation](https://spec.smarthealth.cards/#via-fhir-health-cards-issue-operation)
- Download and validate a health card [via QR Code (Print or Scan)](https://spec.smarthealth.cards/#via-qr-print-or-scan)

The test kit does **NOT** test this requirement:
- Download and validate a health card [via Deep Link](https://spec.smarthealth.cards/#via-deep-link)

## Instructions

It is highly recommended that you use [Docker](https://www.docker.com/) to run
these tests.  This test kit requires at least 10 GB of memory are available to Docker.

- Clone this repo.
- Run `setup.sh` in this repo.
- Run `run.sh` in this repo.
- Navigate to `http://localhost`. The SMART Health Cards test suite will be available.

See the [Inferno Documentation](https://inferno-framework.github.io/docs/)
for more information on running Inferno.

## Documentation
- [Inferno documentation](https://inferno-framework.github.io/docs/)
- [Ruby API documentation](https://inferno-framework.github.io/inferno-core/docs/)
- [JSON API documentation](https://inferno-framework.github.io/inferno-core/api-docs/)

## License
Copyright 2024

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Trademark Notice

HL7, FHIR and the FHIR [FLAME DESIGN] are the registered trademarks of Health
Level Seven International and their use does not constitute endorsement by HL7.
