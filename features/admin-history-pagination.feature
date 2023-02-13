@design-system-only
Feature: Viewing a document's history

  Background:
    Given I am a writer
    And a draft news article "Stubble to be Outlawed" exists
    And "Stubble to be Outlawed" has lots of history and internal notes
    And I am on the edit page for news article "Stubble to be Outlawed"
    And I click the "History" tab

  Scenario: Viewing multiple pages of history
    Then I can see the ten most recent timeline entries

    When I click the "Older" history link
    Then I can see the second page of timeline entries

    When I click the "Newer" history link
    Then I can see the ten most recent timeline entries

  @javascript
  Scenario: Viewing multiple pages of history with JavaScript
    Then I can see the ten most recent timeline entries

    When I click the "Older" history link
    Then I can see the second page of timeline entries

    When I click the "Newer" history link
    Then I can see the ten most recent timeline entries

  Scenario: Filtering the history
    Then I can see the ten most recent timeline entries

    When I set the filter to show "Document history"
    Then I can only see the history

    When I set the filter to show "Internal notes"
    Then I can only see the internal notes

    When I click the "Older" history link
    Then I can see the second page of internal notes

    When I click the "Newer" history link
    Then I can only see the internal notes

    When I set the filter to show "Everything"
    Then I can see the ten most recent timeline entries

  @javascript
  Scenario: Filtering the history with JavaScript
    Then I can see the ten most recent timeline entries

    When I set the filter to show "Document history"
    Then I can only see the history

    When I set the filter to show "Internal notes"
    Then I can only see the internal notes

    When I click the "Older" history link
    Then I can see the second page of internal notes

    When I click the "Newer" history link
    Then I can only see the internal notes

    When I set the filter to show "Everything"
    Then I can see the ten most recent timeline entries
