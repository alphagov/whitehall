Feature: Administering world location information

  Background:
    Given I am an admin

  Scenario: Featuring news on an world location page
    Given a world location "Jamestopia" exists
    And a published news article "You must buy the X-Factor single, says Queen" exists relating to the world location "Jamestopia" produced 4 days ago
    When I feature the news article "You must buy the X-Factor single, says Queen" for world location "Jamestopia" with image "minister-of-funk.960x640.jpg"
    Then I should see the featured items of the world location "Jamestopia" are:
      | You must buy the X-Factor single, says Queen | s300_minister-of-funk.960x640.jpg |

  Scenario: Defining the order of featured news on an organisation page
    Given a world location "Jamestopia" exists
    And a published news article "You must buy the X-Factor single, says Queen" exists relating to the world location "Jamestopia" produced 4 days ago
    And a published news article "Simon Cowell to receive dubious honour" exists relating to the world location "Jamestopia" produced 2 days ago
    And a published news article "Bringing back the Charleston" exists relating to the world location "Jamestopia" produced 3 days ago
    And I feature the news article "Bringing back the Charleston" for world location "Jamestopia"
    And I feature the news article "You must buy the X-Factor single, says Queen" for world location "Jamestopia"
    When I order the featured items of the world location "Jamestopia" to:
      |You must buy the X-Factor single, says Queen|
      |Bringing back the Charleston|
    Then I should see the featured items of the world location "Jamestopia" are:
      |You must buy the X-Factor single, says Queen|
      |Bringing back the Charleston|

  Scenario: Creating offsite content on a world location page
    Given a world location "Jamestopia" exists
    When I add the offsite link "Offsite Thing" of type "Alert" to the world location "Jamestopia"
    Then I should see the edit offsite link "Offsite Thing" on the "Jamestopia" world location page

  Scenario: Featuring offsite content on a world location page
    Given a world location "Jamestopia" exists
    And I have an offsite link "Offsite Thing" for the world location "Jamestopia"
    When I feature the offsite link "Offsite Thing" for  world location "Jamestopia" with image "minister-of-funk.960x640.jpg"
    Then I should see the featured items of the world location "Jamestopia" are:
      | Offsite Thing | s300_minister-of-funk.960x640.jpg |
    When I stop featuring the offsite link "Offsite Thing" for the world location "Jamestopia"
    Then there should be nothing featured on the home page of world location "Jamestopia"

  Scenario: Viewing the list presents world locations in name order, ignoring "The" accents, grouped by first letter
    Given a world location "Special Republic" exists
    And a world location "Spëcial Kingdom" exists
    And a world location "The Excellent Free States" exists
    And a world location "Egg Island" exists
    And a world location "Échouéland" exists
    And a world location "Special Isles" exists
    When I visit the world locations page
    Then I should see the following world locations grouped under "E" in order:
      | Échouéland |
      | Egg Island |
      | The Excellent Free States |
    And I should see the following world locations grouped under "S" in order:
      | Special Isles |
      | Spëcial Kingdom |
      | Special Republic |
