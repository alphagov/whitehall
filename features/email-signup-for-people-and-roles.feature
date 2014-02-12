Feature: Email signup for people and roles

  Background:
    Given I am a GDS editor
    And govuk delivery exists
    And "Marty McFly" is the "Minister of Anachronisms" for the "Department of Temporal Affairs"
    And a published news article "News from Marty McFly" associated with "Marty McFly"

  Scenario: Signing up to role alerts
    Given I visit the role page for "Minister of Anachronisms"
    When I sign up for emails
    Then I should be signed up for the "Minister of Anachronisms" role mailing list

    When I publish a news article "More news" associated with "Marty McFly"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for

  Scenario: Signing up to people alerts
    Given I visit the person page for "Marty McFly"
    When I sign up for emails
    Then I should be signed up for the "Marty McFly" person mailing list

    When I publish a news article "More news" associated with "Marty McFly"
    Then a govuk_delivery notification should have been sent to the mailing list I signed up for
