@not-quite-as-fake-search
Feature: Viewing statistics

  Scenario: Citizen visits a translated list of statistics and paginates
    Given there are some Welsh statistics
    When I visit the Welsh statistics index page
    Then I can see the first page of all the statistics
    When I navigate to the next page of statistics
    Then I can see the second page of all the statistics
