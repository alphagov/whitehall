Feature: Review reminders
  In order to allow publishers to maintain content
  An editor
  Should be able to set and edit a review date for a document

  Background:
  Given I am an editor

  Scenario: Creating a new draft publication with a review date
    When I start drafting a new publication "Standard Beard Lengths"
    And I add a review date of "2033-1-1" and the email address "test@gmail.com" on the edit page
    Then I should see the review date of "1 January 2033" on the edition summary page

  Scenario: Creating a review date for a published publication
    Given a published publication "Standard Beard Lengths" with a PDF attachment
    When I click the button "Create new review date" on the edition summary page for "Standard Beard Lengths"
    And I add a review date of "2033-1-1" and the email address "test@gmail.com"
    Then I should see the review date of "1 January 2033" on the edition summary page

  Scenario: Editing the review date for a published publication
    Given a published publication "Standard Beard Lengths" with a PDF attachment
    And a review reminder exists for "Standard Beard Lengths" with the date "2032-1-1"
    When I click the button "Edit review date" on the edition summary page for "Standard Beard Lengths"
    And I update the review date to "2033-1-1"
    Then I should see the review date of "1 January 2033" on the edition summary page
