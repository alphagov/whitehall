Feature: Administering world location information
  Scenario: Viewing the list presents world locations in name order, ignoring "The" accents, grouped by first letter
    Given a world location "Special Republic" exists
    And a world location "Spëcial Kingdom" exists
    And a world location "The Excellent Free States" exists
    And a world location "Egg Island" exists
    And a world location "Échouéland" exists
    And a world location "Special Isles" exists
    And an international delegation "UK and the World Government" exists
    When I visit the world locations page
    Then I should see the following world locations grouped under "E" in order:
      | Échouéland                |
      | Egg Island                |
      | The Excellent Free States |
    And I should see the following world locations grouped under "S" in order:
      | Special Isles    |
      | Spëcial Kingdom  |
      | Special Republic |
    And I should see the following international delegations in order:
      | UK and the World Government |
