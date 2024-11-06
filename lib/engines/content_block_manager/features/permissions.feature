Feature: Content Block Manager Permissions

  Scenario: GDS editor cannot access the content block manager
    Given I am a GDS editor
    When I visit the Content Block Manager home page
    Then I should see a permissions error

  Scenario: GDS admin can access the content block manager
    Given I am a GDS admin
    When I visit the Content Block Manager home page
    Then I should see the content block manager home page

  Scenario: GDS editor can access the content block manager in non-production environments
    Given I am in the staging or integration environment
    And I am a GDS editor
    When I visit the Content Block Manager home page
    Then I should see the content block manager home page
