Feature: Linking to public website from administration screens
  To quickly view documents in situ on the public website
  A writer
  Should be able navigate to the public documents from the admin interfaces

  Background:
    Given I am a writer

  Scenario: Viewing a published document
    Given a published publication "A Publication" with a PDF attachment
    Then I should see a link to the public version of the publication "A Publication"
