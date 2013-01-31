Feature: Administering world location information

  Background:
    Given I am an admin

  Scenario: Adding embassy contact details
    Given a country "France" exists
    When I add contact details for the embassy in "France"
    When I view the country "France"
    Then I should see contact details for the embassy in "France"

  Scenario: Featuring news on an world location page
    Given an overseas territory "Jamestopia" exists
    And a published news article "You must buy the X-Factor single, says Queen" exists relating to the overseas territory "Jamestopia" produced 4 days ago
    When I feature the news article "You must buy the X-Factor single, says Queen" for overseas territory "Jamestopia" with image "minister-of-funk.960x640.jpg"
    Then I should see the featured items of the overseas territory "Jamestopia" are:
      | You must buy the X-Factor single, says Queen | s630_minister-of-funk.960x640.jpg |

  Scenario: Defining the order of featured news on an organisation page
    Given an overseas territory "Jamestopia" exists
    And a published news article "You must buy the X-Factor single, says Queen" exists relating to the overseas territory "Jamestopia" produced 4 days ago
    And a published news article "Simon Cowell to receive dubious honour" exists relating to the overseas territory "Jamestopia" produced 2 days ago
    And a published news article "Bringing back the Charleston" exists relating to the overseas territory "Jamestopia" produced 3 days ago
    And I feature the news article "Bringing back the Charleston" for overseas territory "Jamestopia"
    And I feature the news article "You must buy the X-Factor single, says Queen" for overseas territory "Jamestopia"
    When I order the featured items of the overseas territory "Jamestopia" to:
      |Bringing back the Charleston|
      |You must buy the X-Factor single, says Queen|
    Then I should see the featured items of the overseas territory "Jamestopia" are:
      |Bringing back the Charleston|
      |You must buy the X-Factor single, says Queen|
