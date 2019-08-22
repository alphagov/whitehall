Feature: Email signup information for organisations
  The MHRA has a need for more specialised email alerts and as such, has a
  custom email signup page where uses can sign up for specific drug alerts. The
  organisation home page links to this custom page rather than the standard
  atom-based email signup page.

  Scenario: Signing up to custom organisation email alerts for the MHRA
    Given the organisation "Medicines and healthcare products regulatory agency" exists with a featured article
    When I visit the "Medicines and healthcare products regulatory agency" organisation
    And click the link for the latest email alerts
    Then I should see email signup information for "Medicines and healthcare products regulatory agency"
