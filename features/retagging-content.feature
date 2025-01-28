Feature: Retagging documents to different organisations
  As an editor
  I want to be able to retag published documents
  So that they reflect changes to lead and supporting organisations

  Background:
    Given I am a GDS admin

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
