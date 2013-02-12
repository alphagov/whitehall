Feature: Administering world location information

  Background:
    Given I am an admin

  Scenario: Featuring news on an world location page
    Given an overseas territory "Jamestopia" exists
    And a published news article "You must buy the X-Factor single, says Queen" exists relating to the overseas territory "Jamestopia" produced 4 days ago
    When I feature the news article "You must buy the X-Factor single, says Queen" for overseas territory "Jamestopia" with image "minister-of-funk.960x640.jpg"
    Then I should see the featured items of the overseas territory "Jamestopia" are:
      | You must buy the X-Factor single, says Queen | s300_minister-of-funk.960x640.jpg |

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

  Scenario: Adding a new translation
    Given a country "Afrolasia" exists with the mission statement "The UK has a long-standing relationship with Afrolasia"
    When I add a new translation to the country "Afrolasia" with:
      | locale            | fr                                                          |
      | name              | Afrolasie                                                   |
      | mission_statement | Le Royaume-Uni a une relation de longue date avec Afrolasie |
    Then when viewing the country "Afrolasia" with the locale "fr" I should see:
      | name              | Afrolasie                                                   |
      | mission_statement | Le Royaume-Uni a une relation de longue date avec Afrolasie |

  Scenario: Editing an existing translation
    Given a country "Afrolasia" exists with a translation for the locale "fr"
    When I edit the "fr" translation for "Afrolasia" setting:
      | locale            | fr                                                          |
      | name              | Afrolandie                                                  |
      | mission_statement | Enseigner aux gens comment infuser le thé                   |
    Then when viewing the country "Afrolasia" with the locale "fr" I should see:
      | name              | Afrolandie                                                  |
      | mission_statement | Enseigner aux gens comment infuser le thé                   |
