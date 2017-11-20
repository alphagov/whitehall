Feature: Administering world location information

  Background:
    Given I am an admin

  Scenario: Featuring news on an international delegation page
    Given an international delegation "Jamestopia" exists
    And a published news article "You must buy the X-Factor single, says Queen" exists relating to the international delegation "Jamestopia" produced 4 days ago
    When I feature the news article "You must buy the X-Factor single, says Queen" for international delegation "Jamestopia" with image "minister-of-funk.960x640.jpg"
    Then I should see the featured items of the international delegation "Jamestopia" are:
      | You must buy the X-Factor single, says Queen | s300_minister-of-funk.960x640.jpg |

  Scenario: Defining the order of featured news on an organisation page
    Given an international delegation "Jamestopia" exists
    And a published news article "You must buy the X-Factor single, says Queen" exists relating to the international delegation "Jamestopia" produced 4 days ago
    And a published news article "Simon Cowell to receive dubious honour" exists relating to the international delegation "Jamestopia" produced 2 days ago
    And a published news article "Bringing back the Charleston" exists relating to the international delegation "Jamestopia" produced 3 days ago
    And I feature the news article "Bringing back the Charleston" for international delegation "Jamestopia"
    And I feature the news article "You must buy the X-Factor single, says Queen" for international delegation "Jamestopia"
    When I order the featured items of the international delegation "Jamestopia" to:
      |You must buy the X-Factor single, says Queen|
      |Bringing back the Charleston|
    Then I should see the featured items of the international delegation "Jamestopia" are:
      |You must buy the X-Factor single, says Queen|
      |Bringing back the Charleston|

  Scenario: Creating offsite content on an international delegation page
    Given an international delegation "Jamestopia" exists
    When I add the offsite link "Offsite Thing" of type "Alert" to the international delegation "Jamestopia"
    Then I should see the edit offsite link "Offsite Thing" on the "Jamestopia" international delegation page

  Scenario: Featuring offsite content on an international delegation page
    Given an international delegation "Jamestopia" exists
    And I have an offsite link "Offsite Thing" for the international delegation "Jamestopia"
    When I feature the offsite link "Offsite Thing" for international delegation "Jamestopia" with image "minister-of-funk.960x640.jpg"
    Then I should see the featured items of the international delegation "Jamestopia" are:
      | Offsite Thing | s300_minister-of-funk.960x640.jpg |
    When I stop featuring the offsite link "Offsite Thing" for the international delegation "Jamestopia"
    Then there should be nothing featured on the home page of international delegation "Jamestopia"

  Scenario: Viewing the list presents world locations in name order, ignoring "The" accents, grouped by first letter
    Given a world location "Special Republic" exists
    And a world location "Spëcial Kingdom" exists
    And a world location "The Excellent Free States" exists
    And a world location "Egg Island" exists
    And a world location "Échouéland" exists
    And a world location "Special Isles" exists
    And an international delegation "UK and the World Government" exists
    When I visit the world locations page
    Then I should see the following world locations grouped under "E" in order:
      | Échouéland |
      | Egg Island |
      | The Excellent Free States |
    And I should see the following world locations grouped under "S" in order:
      | Special Isles |
      | Spëcial Kingdom |
      | Special Republic |
    And I should see the following international delegations in order:
      | UK and the World Government |
