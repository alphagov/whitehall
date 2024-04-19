Feature: Republishing published documents
  As an editor
  I want to be able to republish published documents
  So that they reflect changes to their dependencies when this doesn't happen automatically

  Background:
    Given I am a GDS admin

  Scenario: Republish the "Past prime ministers" page
    Given a published publication "Past prime ministers" exists
    And the "Past prime ministers" page can be republished
    When I request a republish of the "Past prime ministers" page
    Then I can see the "Past prime ministers" page has been scheduled for republishing

  Scenario: Republish an organisation
    Given a published organisation "An Existing Organisation" exists
    And the "An Existing Organisation" organisation can be republished
    When I request a republish of the "An Existing Organisation" organisation
    Then I can see the "An Existing Organisation" organisation has been scheduled for republishing
