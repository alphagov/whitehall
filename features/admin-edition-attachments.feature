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

    Scenario: Creating a news article with an attachment
      When I start drafting a news article
      And I add an attachment
      Then I should see the attachment listed on the form with it's markdown code
      When I save the news article
      Then I should see the attachment listed on the attachments tab

    Scenario: Creating a publication with an attachment
      When I start drafting a publication
      And I add an attachment with additional references
      Then I should see the attachment listed on the form
      When I save the publication
      Then I should see the attachment listed on the attachments tab

    Scenario: Creating a statistical data set with an attachment
      When I start drafting a statistical data set
      And I add an attachment with additional references
      Then I should see the attachment listed on the form with it's markdown code
      When I save the statistical data set
      Then I should see the attachment listed on the attachments tab

    Scenario: Creating a consultation with an attachment
      When I start drafting a consultation
      And I add an attachment with additional references
      Then I should see the attachment listed on the form
      When I save the consultation
      Then I should see the attachment listed on the attachments tab

    Scenario: Updating an attachment on an edition
      Given a draft publication "Blah blah" with a PDF attachment
      When I edit the attachment changing the title to "Something else"
      Then the attachment should be titled "Something else"

    # Scenario: Removing an attachment from an edition

    # Scenario: Adding a response to a consultation!!
