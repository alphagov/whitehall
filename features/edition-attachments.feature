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
    Given I am a writer in the organisation "Ministry of Grooming"

    Scenario: Creating an edition with an attachment
      When I start drafting a news article
      And I add an attachment
      Then I should see the attachment listed on the form with it's markdown code
      When I save the news article
      Then I should see the attachment listed on the attachments tab

    Scenario: Updating an attachment on an edition
      Given a draft publication "Blah blah" with a PDF attachment
      When I edit the attachment changing the title to "Something else"
      Then the attachment should be titled "Something else"

    Scenario: Bulk uploading attachments
      Given a draft news article "News article title" exists
      When I upload multiple attachments as a zip file, providing titles for each file
      Then I should see the attachments listed on the form
