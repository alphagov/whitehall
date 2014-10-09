Feature: Email signup information for organisations

  Scenario: Signing up to organisation alerts
    Given the organisation "Medicines and healthcare products regulatory agency" exists
    When I visit the "Medicines and healthcare products regulatory agency" organisation email signup information page
    Then I should see email signup information for "Medicines and healthcare products regulatory agency"
