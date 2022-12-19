Feature: Viewing a documents history

  Background:
    Given I am a writer

  @design-system-only
  Scenario: Viewing multiple pages of history
    Given a draft news article "Stubble to be Outlawed" exists
    When "Stubble to be Outlawed" has two pages of history
    Then I can see the first ten items in the History tab

    When I click the "Older" link
    Then I can see the second page of history

    When I click the "Newer" link
    Then I can see the first ten items in the History tab

  @javascript @design-system-only
  Scenario: Viewing multiple pages of history with JavaScript
    Given a draft news article "Stubble to be Outlawed" exists
    When "Stubble to be Outlawed" has two pages of history
    Then I can see the first ten items in the History tab

    When I click the "Older" link
    Then I can see the second page of history
    And the History tab is still showing

    When I click the "Newer" link
    Then I can see the first ten items in the History tab
    And the History tab is still showing
