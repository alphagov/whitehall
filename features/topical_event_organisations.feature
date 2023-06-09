@design-system-only
Feature:
  As an Editor.
  I want to be able to view and manage topical_event_organisations.
  So that I can order organisations and designate as lead or supporting.

  Background:
    Given I am a GDS admin
    And a topical event called "Really topical" exists
    And the topical event has a lead organisation called "Lead organisation"
    And the topical event has a supporting organisation called "Supporting organisation"

  Scenario: View topical event organisations
    When I visit the topical event organisations index page
    Then I can see the lead organisation with the name "Lead organisation"
    And I can see the supporting organisation with the name "Supporting organisation"
