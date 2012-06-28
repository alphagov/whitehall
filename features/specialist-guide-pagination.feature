@javascript
Feature: Paginating long specialist guides
  As a consumer of specialist guides
  I want to be able to navigate easily around the content within a long guide
  So that I can digest it more easily

  Scenario: Break the guide up into pages
    Given a specialist guide with section headings
    When I view the specialist guide
    Then I should see only the first page of the specialist guide

    When I navigate to the second page of the specialist guide
    Then I should see only the second page of the specialist guide

  Scenario: Hide the summary on later pages
    Given a specialist guide with section headings
    When I view the first page of the specialist guide
    Then I should see the specialist guide summary

    When I navigate to the second page of the specialist guide
    Then I should not see the specialist guide summary

  Scenario: Navigate within a page
    Given a specialist guide with section headings
    When I view the first page of the specialist guide
    Then I should not see navigation for headings within other specialist guide pages

    When I view a specialist guide page with internal headings
    Then I should see navigation for the headings within that specialist guide page
