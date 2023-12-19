Feature: Editionable worldwide organisations
  Background:
    Given I am a writer
    And The editionable worldwide organisations feature flag is enabled

  Scenario Outline: Creating a new draft worldwide organisation
    When I draft a new worldwide organisation "Test Worldwide Organisation"
    Then the worldwide organisation "Test Worldwide Organisation" should have been created
