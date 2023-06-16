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

  Scenario: Reorder lead organisations
    Given the topical event has a lead organisation called "Another lead organisation"
    When I visit the topical event organisations index page
    And I set the order of lead organisations to:
      | name                      | order |
      | Lead organisation         | 1     |
      | Another lead organisation | 0     |
    Then I can see a "Lead organisations have been reordered." success notice
    And the lead organisations should be in the following order:
      | name                      |
      | Another lead organisation |
      | Lead organisation         |

  Scenario: Make lead organisation
    When I visit the topical event organisations index page
    And I make "Supporting organisation" a lead organisation
    Then I can see a "Supporting organisation has been assigned as a lead organisation." success notice
    And I can see the lead organisation with the name "Supporting organisation"

  Scenario: Make supporting organisation
    When I visit the topical event organisations index page
    And I make "Lead organisation" a supporting organisation
    Then I can see a "Lead organisation has been assigned as a supporting organisation." success notice
    And I can see the supporting organisation with the name "Lead organisation"
