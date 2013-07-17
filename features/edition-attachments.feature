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
