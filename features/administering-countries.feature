Feature: Administering country information

Background:
  Given I am an admin

Scenario: Adding embassy contact details
  Given a country "France" exists
  When I add contact details for the embassy in "France"
  When I view the country "France"
  Then I should see contact details for the embassy in "France"