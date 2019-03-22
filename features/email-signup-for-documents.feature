Feature: Email signup for documents

  Background:
    Given I am a GDS editor
    And email alert api exists
    And a list of publications exists

  @not-quite-as-fake-search
  Scenario: Signing up to unfiltered publications alerts
    When I visit the list of publications
    And I sign up for emails
    Then I should be signed up for the all publications mailing list

  @not-quite-as-fake-search
  Scenario: Signing up to filtered publications alerts
    When I filter the publications list by "Correspondence"
    And I sign up for emails
    Then I should be signed up to the correspondence publications mailing list
