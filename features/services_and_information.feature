Feature: Services and information page for organisations

Background:
  Given the organisation "Cabinet Office" exists with featured services and guidance

Scenario: Viewing the services and information page for an org
    When I view the services and information page for the "Cabinet Office" organisation
    Then I should see a list of sub-sectors in which some documents are related to the Cabinet Office organisation, with a list of documents in each sub-sector
