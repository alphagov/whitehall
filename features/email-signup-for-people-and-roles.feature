Feature: Email signup for people and roles

  Background:
    Given I am a GDS editor
    And "Marty McFly" is the "Minister of Anachronisms" for the "Department of Temporal Affairs"
    And "Dave Example" is the "Minister of Examples" for the "Department of Examples"
    And a published news article "News from Marty McFly" associated with "Marty McFly"

  Scenario: Signing up to role alerts
    Given I visit the role page for "Minister of Anachronisms"
    Then a govuk_delivery signup should be sent for the feed subscription URL
    When I sign up for emails

    Then a notification should be sent for subscribers to the role "Minister of Anachronisms" and for subscribers to the person "Marty McFly"
    When I publish a news article "More news" associated with "Marty McFly"

    And a notification should be not sent for subscribers to the role "Minister of Anachronisms" or for subscribers to the person "Marty McFly"
    When I publish a news article "Irrelevant news" associated with "Dave Example"

  Scenario: Signing up to people alerts
    Given I visit the person page for "Marty McFly"
    Then a govuk_delivery signup should be sent for the feed subscription URL
    When I sign up for emails

    Then a notification should be sent for subscribers to the role "Minister of Anachronisms" and for subscribers to the person "Marty McFly"
    When I publish a news article "More news" associated with "Marty McFly"

    And a notification should be not sent for subscribers to the role "Minister of Anachronisms" or for subscribers to the person "Marty McFly"
    When I publish a news article "Irrelevant news" associated with "Dave Example"
