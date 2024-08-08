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
    When I request a republish of the "How government works" page
    Then I can see the "How government works" page has been scheduled for republishing

  Scenario: Republish the "Fields of operation" page
    Given a published publication "Fields of operation" exists
    When I request a republish of the "Fields of operation" page
    Then I can see the "Fields of operation" page has been scheduled for republishing

  Scenario: Republish the "Ministers" page
    Given a published publication "Ministers" exists
    When I request a republish of the "Ministers" page
    Then I can see the "Ministers" page has been scheduled for republishing

  Scenario: Republish the "Find a British embassy, high commission or consulate" page
    Given a published publication "Find a British embassy, high commission or consulate" exists
    When I request a republish of the "Find a British embassy, high commission or consulate" page
    Then I can see the "Find a British embassy, high commission or consulate" page has been scheduled for republishing

  Scenario: Republish the "Help and services around the world" page
    Given a published publication "Help and services around the world" exists
    When I request a republish of the "Help and services around the world" page
    Then I can see the "Help and services around the world" page has been scheduled for republishing

  Scenario: Republish the "Departments, agencies and public bodies" page
    Given a published publication "Departments, agencies and public bodies" exists
    When I request a republish of the "Departments, agencies and public bodies" page
    Then I can see the "Departments, agencies and public bodies" page has been scheduled for republishing

  Scenario: Republish an organisation
    Given a published organisation "An Existing Organisation" exists
    When I request a republish of the "An Existing Organisation" organisation
    Then I can see the "An Existing Organisation" organisation has been republished

  Scenario: Republish a person
    Given a published person "Existing Person" exists
    When I request a republish of the "Existing Person" person
    Then I can see the "Existing Person" person has been republished

  Scenario: Republish a role
    Given a published role "An Existing Role" exists
    When I request a republish of the "An Existing Role" role
    Then I can see the "An Existing Role" role has been republished

  Scenario: Republish a document
    Given a document with slug "an-existing-document" exists
    When I request a republish of the "an-existing-document" document's editions
    Then I can see the "an-existing-document" document's editions have been republished
