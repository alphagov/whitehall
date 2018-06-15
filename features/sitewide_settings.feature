Feature: Sitewide settings

  Scenario: Minister counts should not be visible during minister reshuffle
    Given we are during a reshuffle
    When I visit the How Government Works page
    Then I should not see the minister counts

  Scenario: A warning should appear on the ministers list during minister reshuffle
    Given we are during a reshuffle
    When I visit the ministers page
    Then I should see a reshuffle warning message
    And I should not see the ministers and cabinet

  Scenario: Minister counts should be visible outside of a minister reshuffle
    Given we are not during a reshuffle
    When I visit the How Government Works page
    Then I should see the minister counts

  Scenario: A warning should not appear on the ministers list outside of a minister reshuffle
    Given we are not during a reshuffle
    When I visit the ministers page
    Then I should not see a reshuffle warning message
