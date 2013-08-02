Feature: Managing attachments on editions

  Background:
    Given I am a writer

    @javascript
    Scenario: Changes on an edition are not lost when adding attachments
      Given a draft news article "Stubble to be Outlawed" exists
      When I make unsaved changes to the news article
      And I attempt to visit the attachments page
      Then I should stay on the edit screen for the news article
      When I save my changes
      Then I can visit the attachments page

    Scenario: Replacing data on an attachment
      Given I am an editor
      And a published publication "Standard Beard Lengths" with a PDF attachment
      And the attachment has been virus-checked
      When I replace the data file of the attachment in a new draft of the publication
      And the attachment has been virus-checked
      Then the new data file should not be public
      When I published the draft edition
      And I log out
      Then the new data file should be public
      And the old data file should redirect to the new data file
