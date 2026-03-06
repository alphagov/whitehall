Feature: Creating and publishing topical events
  As an editor
  I want to be able to create and publish topical events
  So that I can communicate about them

  Background:
    Given I am an editor
    Given search returns no results

  # TODO: We'll want to write an equivalent test for this when we implement config-driven multi page architecture
  Scenario: Adding more information about the event
    Given I'm administering a topical event
    And I add a page of information about the event
    Then I should be able to edit the event's about page
    And I should see the about page is updated
