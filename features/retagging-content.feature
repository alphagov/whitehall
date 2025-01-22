Feature: Retagging documents to different organisations
  As an editor
  I want to be able to retag published documents
  So that they reflect changes to lead and supporting organisations

  Background:
    Given I am a GDS admin

  Scenario: Dry run of the retagging - invalid data
    Given the documents and organisations I am retagging contain errors
    When I visit the retagging page
    And I submit my CSV of documents to be retagged
    Then I should be on the retagging page with my CSV input still present
    And I should see a summary of retagging errors
