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

  Scenario: Dry run of the retagging - valid data
    Given the documents and organisations I am retagging exist
    When I visit the retagging page
    And I submit my CSV of documents to be retagged
    Then I can see a summary of the proposed changes
    And my CSV input should be in a hidden field ready to confirm retagging

  Scenario: Full run of the retagging
    Given the documents and organisations I am retagging exist
    When I visit the retagging page
    And I submit my CSV of documents to be retagged
    Then I can see a summary of the proposed changes
    And my CSV input should be in a hidden field ready to confirm retagging
    And when I click "Publish changes" on this retagging screen
    Then I am redirected to the retagging index page
    And I see a confirmation message that my documents are being retagged
    And the changes should have been actioned
