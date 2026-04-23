Feature: Editing existing legacy topical events
  As an editor
  I want to be able to edit and publish existing legacy topical events

  Background:
    Given I am an editor

  Scenario: Adding more information about the event
    Given I'm administering a topical event
    And I add a page of information about the event
    Then I should be able to edit the event's about page
    And I should see the about page is updated

  Scenario: Deleting a topical event
    Given a topical event called "An event" with summary "A topical event" and description "A topical event"
    Then I should be able to delete the topical event "An event"