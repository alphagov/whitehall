Feature: Editionable worldwide organisations
  In order to allow the public to view worldwide organisations
  A writer and editor
  Should be able to draft and publish worldwide organisations

  Background:
    Given I am a writer
    And The editionable worldwide organisations feature flag is enabled

  Scenario Outline: Creating a new draft worldwide organisation
    When I draft a new worldwide organisation "British Antarctic Territory"
    # TODO: Need the assertion that we can see the draft in the list after the Publishing API Presenter has been merged!
#    Then I should see the editionable worldwide organisation "British Antarctic Territory" in the list of draft documents
