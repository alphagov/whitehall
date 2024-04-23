Feature: Republishing published documents
  As an editor
  I want to be able to republish published documents
  So that they reflect changes to their dependencies when this doesn't happen automatically

  Background:
    Given I am a GDS admin

  Scenario: Republish the "Past Prime Ministers" page
    Given a published publication "Past Prime Ministers" exists
    And the "Past Prime Ministers" page can be republished
    When I request a republish of the "Past Prime Ministers" page
    Then I can see the "Past Prime Ministers" page has been scheduled for republishing

  Scenario: Republish the "How government works" page
    Given a published publication "How government works" exists
    And the "How government works" page can be republished
    When I request a republish of the "How government works" page
    Then I can see the "How government works" page has been scheduled for republishing

  Scenario: Republish the "Fields of operation" page
    Given a published publication "Fields of operation" exists
    And the "Fields of operation" page can be republished
    When I request a republish of the "Fields of operation" page
    Then I can see the "Fields of operation" page has been scheduled for republishing

  Scenario: Republish the "Ministers" page
    Given a published publication "Ministers" exists
    And the "Ministers" page can be republished
    When I request a republish of the "Ministers" page
    Then I can see the "Ministers" page has been scheduled for republishing

  Scenario: Republish the "Find a British embassy, high commission or consulate" page
    Given a published publication "Find a British embassy, high commission or consulate" exists
    And the "Find a British embassy, high commission or consulate" page can be republished
    When I request a republish of the "Find a British embassy, high commission or consulate" page
    Then I can see the "Find a British embassy, high commission or consulate" page has been scheduled for republishing

  Scenario: Republish the "Help and services around the world" page
    Given a published publication "Help and services around the world" exists
    And the "Help and services around the world" page can be republished
    When I request a republish of the "Help and services around the world" page
    Then I can see the "Help and services around the world" page has been scheduled for republishing

  Scenario: Republish the "Departments, agencies and public bodies" page
    Given a published publication "Departments, agencies and public bodies" exists
    And the "Departments, agencies and public bodies" page can be republished
    When I request a republish of the "Departments, agencies and public bodies" page
    Then I can see the "Departments, agencies and public bodies" page has been scheduled for republishing

  Scenario: Republish an organisation
    Given a published organisation "An Existing Organisation" exists
    And the "An Existing Organisation" organisation can be republished
    When I request a republish of the "An Existing Organisation" organisation
    Then I can see the "An Existing Organisation" organisation has been scheduled for republishing

  Scenario: Republish a person
    Given a published person "Existing Person" exists
    And the "Existing Person" person can be republished
    When I request a republish of the "Existing Person" person
    Then I can see the "Existing Person" person has been scheduled for republishing

  Scenario: Republish a role
    Given a published role "An Existing Role" exists
    And the "An Existing Role" role can be republished
    When I request a republish of the "An Existing Role" role
    Then I can see the "An Existing Role" role has been scheduled for republishing
