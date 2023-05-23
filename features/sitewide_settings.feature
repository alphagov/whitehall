Feature: Sitewide settings

  Scenario: There are no sitewide settings available to edit
    Given that there no sidewide settings available to edit
    And I am an admin
    When I visit the sitewide settings page
    Then I should see an empty status message
