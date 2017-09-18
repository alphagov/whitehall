Feature: Email signup for topics

  Background:
    Given I am a GDS editor
    And email alert api exists
    And a topic called "Wombat management" exists with featured documents

  Scenario: Signing up to topic alerts
    Given I visit the "Wombat management" topic
    When I sign up for emails
    Then I should be signed up for the "Wombat management" topic mailing list
