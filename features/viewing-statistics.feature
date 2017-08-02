@not-quite-as-fake-search
Feature: Viewing statistics

  Scenario: Citizen filters the list of statistics and uses the pagination
    Given there are some statistics
    When I visit the statistics index page
    Then I can see the first page of all the statistics
    When I navigate to the next page of statistics
    Then I can see the second page of all the statistics
    When I filter the statistics by keyword, from date and to date
    And I should only see statistics matching the given keyword, from date and to date

  Scenario: Citizen filters the list of statistics by department and topic
    Given there are some statisics for various departments and topics
    When I visit the statistics index page
    And I filter the statistics by department and topic
    Then I should only see statistics for the selected departments and topics
