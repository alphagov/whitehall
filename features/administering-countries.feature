Feature: Administering country information

Background:
  Given I am an admin

Scenario: Adding embassy contact details
  Given a country "France" exists
  When I add contact details for the embassy in "France"
  When I view the country "France"
  Then I should see contact details for the embassy in "France"

Scenario: Featuring news on an organisation page most recent first
  Given a country "Jamestopia" exists
  And a published news article "You must buy the X-Factor single, says Queen" exists relating to the country "Jamestopia" produced 4 days ago
  And a published news article "Simon Cowell to receive dubious honour" exists relating to the country "Jamestopia" produced 3 days ago
  And a published news article "Bringing back the Charleston" exists relating to the country "Jamestopia" produced 2 days ago

  When I set the featured news articles of the country "Jamestopia" to:
    |News Article|
    |Bringing back the Charleston|
    |You must buy the X-Factor single, says Queen|
  Then I should see the featured news articles of the country "Jamestopia" are:
    |Bringing back the Charleston|
    |You must buy the X-Factor single, says Queen|