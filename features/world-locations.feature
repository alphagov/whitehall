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

  Scenario: Featuring different things on different locale versions of a world location page
    Given a world location "Jamestopia" exists in both english and french
    And an english news article called "Beards" related to the world location
    When I feature "Beards" on the english "Jamestopia" page
    Then I should see no featured items on the french version of the "Jamestopia" page

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

  Scenario: Featuring shows the correct translation of the article on world location page
    Given a world location "Jamestopia" exists in both english and french
    And there is a news article "Beards" in english ("Barbes" in french) related to the world location
    When I feature "Barbes" on the french "Jamestopia" page
    Then I should see "Barbes" as the title of the featured item on the french "Jamestopia" admin page
    And I should see "Barbes" as the title of the feature on the french "Jamestopia" page

  Scenario: Featuring things that aren't associated with the world location
    Given a world location "Jamestopia" exists in both english and french
    And a published news article "Beards" which isn't explicitly associated with "Jamestopia"
    When I feature "Beards" on the english "Jamestopia" page
    Then I should see "Beards" featured on the public facing "Jamestopia" page
    And I cannot feature "Beards" on the french "Jamestopia" page due to the lack of a translation

  Scenario: Adding a new translation
    Given a world location "Afrolasia" exists with the mission statement "The UK has a long-standing relationship with Afrolasia"
    When I add a new translation to the world location "Afrolasia" with:
      | locale            | Français                                                    |
      | name              | Afrolasie                                                   |
      | title             | UK en Afrolasia                                             |
      | mission_statement | Le Royaume-Uni a une relation de longue date avec Afrolasie |
    Then when viewing the world location "Afrolasia" with the locale "Français" I should see:
      | name              | Afrolasie                                                   |
      | title             | UK en Afrolasia                                             |
      | mission_statement | Le Royaume-Uni a une relation de longue date avec Afrolasie |

  Scenario: Editing an existing translation
    Given a world location "Afrolasia" exists with a translation for the locale "Français"
    When I edit the "Français" translation for "Afrolasia" setting:
      | locale            | Français                                                    |
      | name              | Afrolandie                                                  |
      | title             | UK en Afrolandie                                            |
      | mission_statement | Enseigner aux gens comment infuser le thé                   |
    Then when viewing the world location "Afrolasia" with the locale "Français" I should see:
      | name              | Afrolandie                                                  |
      | title             | UK en Afrolandie                                            |
      | mission_statement | Enseigner aux gens comment infuser le thé                   |

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
