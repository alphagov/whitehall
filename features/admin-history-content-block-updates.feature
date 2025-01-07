Feature: Showing content block updates in history

  Background:
    Given I am an editor
    And a published news article "Stubble to be Outlawed" exists
    And the document has been updated by a change to the content block "Some email address"

  Scenario: Content block update exists for current edition
    When I am on the edit page for news article "Stubble to be Outlawed"
    And I click the "History" tab
    Then I should see an entry for the content block "Some email address" on the current edition

  Scenario: Content block update exists for a previous edition
    Given some time has passed
    When I force publish a new edition of the news article "Stubble to be Outlawed"
    And I am on the edit page for news article "Stubble to be Outlawed"
    And I click the "History" tab
    Then I should see an entry for the content block "Some email address" on the previous edition
