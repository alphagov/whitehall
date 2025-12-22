@disable-sidekiq-test-mode
Feature: Bulk uploading attachments to editions

  Background:
    Given I am a writer

  Scenario: Uploading multiple attachments
    Given a draft publication "Stubble to be Outlawed" exists
    When I bulk upload files and give them titles
    Then I should see that the publication has attachments

  Scenario: Keep existing attachments
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files one with the same filename as an existing file
    And I select keep file for existing file
    And I save the files
    Then I should see that the publication has the new attachment and the existing attachment

  Scenario: Keep existing attachments without new file name
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files one with the same filename as an existing file
    And I select keep file for existing file
    And I do not enter a new file name
    And I save the files
    Then I should see an error of "Attachment data new filename cannot be blank" on the bulk upload page

  Scenario: Keep existing attachments with same file name
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files one with the same filename as an existing file
    And I select keep file for existing file
    And I enter the same name as the existing file
    And I save the files
    Then I should see an error of "File with name "greenpaper.pdf" already attached to document" on the bulk upload page

  Scenario: Replacing existing attachments
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files one with the same filename as an existing file
    And I change the title and select replace for the existing file
    And I save the files
    Then I should see that the publication has the existing attachment with updated title and the new attachment

  Scenario: Cancel upload of existing attachments
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files one with the same filename as an existing file
    And I change the title and select reject for the existing file
    And I save the files
    Then I should see that the publication has the existing attachment with original title and the new attachment

  Scenario: Cancel upload of all attachments
    Given a draft publication "Results of beards survey" with two file attachments existing
    When I only upload existing files
    And I reject all the existing files
    And I save the files
    Then I should see that the publication has the existing attachments with original titles
    And I should see a notice of "No files uploaded" on the edition attachments index page

  Scenario: Handle validation errors for new files when user has chosen to keep the existing file
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files one with the same filename as an existing file
    And I select keep file for existing file
    And I save the files without entering a title for the new attachment
    Then I should see an error of "Title cannot be blank" on the bulk upload page
    And I should see the new file name for the existing file
    And I should not see an option to change Keep or Replace

  Scenario: Handle validation errors for new files when user has chosen to replace the existing file
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files one with the same filename as an existing file
    And I change the title and select replace for the existing file
    And I save the files without entering a title for the new attachment
    Then I should see an error of "Title cannot be blank" on the bulk upload page
    And I should see the current file name for the existing file
    And I should not see an option to change Keep or Replace
