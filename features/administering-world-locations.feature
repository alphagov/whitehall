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
      |Bringing back the Charleston|
      |You must buy the X-Factor single, says Queen|
    Then I should see the featured items of the world location "Jamestopia" are:
      |Bringing back the Charleston|
      |You must buy the X-Factor single, says Queen|

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
