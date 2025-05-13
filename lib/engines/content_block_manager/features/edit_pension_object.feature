Feature: Edit a pension object

  Background:
    Given I am a GDS admin
    And the organisation "Ministry of Example" exists
    And a schema "pension" exists with the following fields:
      | field         | type   | format | required |
      | description   | string | string | true     |
    And the schema "pension" has a subschema with the name "rates" and the following fields:
      | field     | type   | format | required | enum           | pattern          |
      | title     | string | string | true     |                |                  |
      | amount    | string | string | true     |                | £[0-9]+\\.[0-9]+ |
      | frequency | string | string |          | a week,a month |                  |
    And a pension content block has been created
    And that pension has a rate with the following fields:
      | title   | amount  | frequency |
      | My rate | £123.45 | a week    |
    And dependent content exists for a content block

  Scenario: GDS Editor edits a pension object
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "pension"
    Then I should be on the "edit" step
    And I should see a back link to the document page
    When I fill out the form
    Then I should be on the "edit_embedded_rates" step
    And I should see the rates for that block
    And I should not see a button to add a new "rate"
    When I click to edit the first rate
    When I complete the "rate" form with the following fields:
      | title   | amount  | frequency |
      | My rate | £122.50 | a week    |
    Then I should be on the "edit_embedded_rates" step
    And I should see the updated rates for that block
    When I save and continue
    Then I should be on the "review_links" step
    And I should see a back link to the "embedded_objects" step
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
    And I should see the notes on the timeline
    And I should see the edition diff in a table
    And I should see details of my "rate"

  Scenario: Rate steps are skipped when there has been no rates added
    Given my pension content block has no rates
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "pension"
    When I fill out the form
    Then I should be on the "review_links" step
    And I should see a back link to the "edit_draft" step

  Scenario: GDS editor sees notification about an in-progress draft
    When I visit the Content Block Manager home page
    And I click to view the document
    And I click to edit the "pension"
    And I fill out the form
    And I click the cancel link
    And I click to save and come back later
    When I click on the link to continue editing
    And I click save
    Then I should see the rates for that block
