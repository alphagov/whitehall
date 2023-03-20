Feature: Administering world location news information
  @design-system-only
  Scenario: Viewing the list presents no world location news message, when no news exists
    Given no world locations exist
    And I am a GDS admin
    When I visit the world location news page
    Then I should see the "No active world location news" message
    When I click the Inactive tab
    Then I should see the "No inactive world location news" message
