@javascript
Feature: Paginating long specialist guides
  As a consumer of specialist guides
  I want to be able to navigate easily around the content within a long guide
  So that I can digest it more easily

  Scenario: Break the guide up into pages
    Given a specialist guide with section headings
    When I view the guide
    Then I should see only the first page of the guide

    When I navigate to the second page
    Then I should see only the second page of the guide

  Scenario: Hide the summary on later pages
    Given a specialist guide with section headings
    When I view the first page
    Then I should see the guide summary

    When I navigate to the second page
    Then I should not see the guide summary

  Scenario: Navigate within a page
    Given a specialist guide with section headings
    When I view the first page
    Then I should not see navigation for headings within other pages

    When I view a page with internal headings
    Then I should see navigation for the headings within that page
