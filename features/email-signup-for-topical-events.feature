Feature: Email signup for topical events

  Background:
    Given I am a GDS editor
    And email alert api exists
    And a topical event called "Wombat management" exists with featured documents

  Scenario: Signing up to topical event alerts
    Given I visit the "Wombat management" topical event
    When I sign up for emails
    Then I should be signed up for the "Wombat management" topical event mailing list
