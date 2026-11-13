Feature: Content Block Picker

  @javascript
  Scenario: Creating a new document and being able to see Content Block Picker
    Given I am an editor
    And I have the "Content Block Picker User" permission
    When I navigate to the new document page
    Then I should see the Content Block Picker has been instantiated

  @javascript
  Scenario: Creating a new document and not being able to see Content Block Picker when I don't have permission
    Given I am an editor
    When I navigate to the new document page
    Then I should see the Content Block Picker has not been instantiated
