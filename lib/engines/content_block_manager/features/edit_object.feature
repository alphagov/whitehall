Feature: Edit a content object
  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists with the following fields:
      | field         | type   | format | required |
      | description   | string | string | true     |
    And a pension content block has been created
    And dependent content exists for a content block

  Scenario: GDS Editor edits a content object
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "pension"
    Then I should be on the "edit" step
    And I should see a back link to the document page
    When I fill out the form
    Then I should be on the "review_links" step
    And I should see a back link to the "edit_draft" step
    When I continue after reviewing the links
    Then I should be on the "internal_note" step
    And I should see a back link to the "review_links" step
    When I add an internal note
    Then I should be on the "change_note" step
    And I should see a back link to the "internal_note" step
    When I add a change note
    Then I should be on the "schedule_publishing" step
    And I should see a back link to the "change_note" step
    When I choose to publish the change now
    Then I should be on the "review" step
    And I should see a back link to the "schedule_publishing" step
    When I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a published block
    When I click to view the content block
    Then the edition should have been updated successfully
    And I should be taken back to the document page
    And I should see 1 publish events on the timeline
    And I should see the notes on the timeline
    And I should see the edition diff in a table

  Scenario: GDS editor cancels the creation of an object when reviewing links
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click to edit the "pension"
    When I fill out the form
    And I click the cancel link
    And I choose to delete the in-progress draft
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created

  Scenario: GDS editor cancels the creation of an object before scheduling
    When I visit the Content Block Manager home page
    And I click to view the document
    When I click to edit the "pension"
    And I fill out the form
    And I continue after reviewing the links
    When I click the cancel link
    And I choose to delete the in-progress draft
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created

  Scenario: GDS editor cancels the creation of an object before confirming answers
    When I visit the Content Block Manager home page
    And I click to view the document
    When I click to edit the "pension"
    And I fill out the form
    And I continue after reviewing the links
    When I add an internal note
    And I add a change note
    And I choose to publish the change now
    When I click the cancel link
    And I choose to delete the in-progress draft
    Then I should be taken back to the document page
    And no draft Content Block Edition has been created

  Scenario: GDS editor sees validation errors for missing fields
    And a pension content block has been created
    When I visit the Content Block Manager home page
    When I click to view the document
    When I click to edit the "pension"
    And I set all fields to blank
    Then I should see errors for the required fields

  @enable-sidekiq-test-mode
  Scenario: GDS editor can override a previously scheduled object
    Given I have scheduled a change for 7 days in the future
    When I revisit the edit page
    Then I should see a warning telling me there is a scheduled change
    When I make the changes
    And I add an internal note
    And I add a change note
    And I choose to publish the change now
    When I review and confirm my answers are correct
    Then I should be taken to the confirmation page for a published block
    When I click to view the content block
    Then the edition should have been updated successfully

  Scenario: GDS editor still sees live edition when abandoning an edit
    When I am updating a content block
    And I visit the Content Block Manager home page
    Then I should still see the live edition on the homepage

  @javascript
  Scenario: GDS editor can preview a host document
    When I revisit the edit page
    And I save and continue
    When I click on the first host document
    Then the preview page opens in a new tab
    When I click on a link within the frame
    Then I should see the content of the linked page

  Scenario: GDS editor sees notification about an in-progress draft
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "pension"
    And I fill out the form
    And I click the cancel link
    And I click to save and come back later
    Then I should see a notification that a draft is in progress
    When I click on the link to continue editing
    And I update the content block and publish
    When I visit the Content Block Manager home page
    And I click to view the document
    Then I should not see a notification that a draft is in progress
    And there should be no draft editions remaining

