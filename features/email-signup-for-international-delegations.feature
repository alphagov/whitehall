Feature: Email signup for international delegations

  Background:
    Given I am a GDS editor
    And email alert api exists
    And an international delegation "UK and Best City" exists

  Scenario: Signing up to international delegation alerts
    Given I view the international delegation "UK and Best City"
    When I sign up for emails
    Then I should be signed up for the "UK and Best City" international delegation mailing list
