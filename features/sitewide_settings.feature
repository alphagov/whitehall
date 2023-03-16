Feature: Sitewide settings

  Scenario: A warning should appear on the ministers list during minister reshuffle
    Given we are during a reshuffle
    When I visit the ministers page
    Then I should see a reshuffle warning message
    And I should not see the ministers and cabinet

  Scenario: A warning should not appear on the ministers list outside of a minister reshuffle
    Given we are not during a reshuffle
    When I visit the ministers page
    Then I should not see a reshuffle warning message

  Scenario: There are no sitewide settings available to edit
    Given that there no sidewide settings available to edit
    And I am an admin
    When I visit the sitewide settings page
    Then I should see an empty status message
