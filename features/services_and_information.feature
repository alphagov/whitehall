Feature: Services and information page for organisations

Scenario: Viewing the services and information page for an org
    Given the organisation "Cabinet Office" exists with featured services and guidance
    When I view the services and information page for the "Cabinet Office" organisation
    Then I should see a list of sub-sectors in which some documents are related to the Cabinet Office organisation, with a list of documents in each sub-sector

Scenario: Viewing the services and info page for an org without featured services and guidance
    Given the organisation "Driving Standards Agency" exists with no featured services and guidance
    When I view the services and information page for the "Driving Standards Agency" without featured services and guidance
    Then I should get a "404" error
