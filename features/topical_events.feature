Feature: Creating and publishing topical events
  As an editor
  I want to be able to create and publish topical events
  So that I can communicate about them

  Background:
    Given I am an editor
    Given search returns no results

  Scenario: Adding a new topical event
    When I create a new topical event "An Event" with summary "A topical event" and description "About this topical event"
    Then I should see the topical event "An Event" in the admin interface

  Scenario: Archiving a new topical event
    When I create a new topical event "An Event" with summary "A topical event", description "About this topical event" and it ends today
    Then I should see the topical event "An Event" in the admin interface

  Scenario: Adding more information about the event
    Given I'm administering a topical event
    And I add a page of information about the event
    Then I should be able to edit the event's about page
    And I should see the about page is updated

  Scenario: Deleting a topical event
    Given a topical event called "An event" with summary "A topical event" and description "A topical event"
    Then I should be able to delete the topical event "An event"
