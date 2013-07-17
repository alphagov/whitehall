Feature: Managing attachments on editions
  Various edition types support attachments, i.e. Consultations, Detailed Guides
  News Articles, Publications and Statistical Data Sets.

  [MORE PREAMBLE HERE LATER]

  Consultations have weird attachments (i.e. consultation/response) and automatically list all without markdown
  Publications automatically list all attachments without the need for markdown
  Statistical data set support attachments references
  News articles have basic attachments without any references
  Detailed guides have basic attachments without any references


  Attachments are either diplayed automatically when viewing the edition, or are
  explicility linked by placing inline markdown tags in the body of the edition.

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
