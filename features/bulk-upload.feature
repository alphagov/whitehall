@disable-sidekiq-test-mode
Feature: Bulk uploading attachments to editions

  Background:
    Given I am a writer

  Scenario: Uploading mulitple attachments
    Given a draft news article "Stubble to be Outlawed" exists
    When I bulk upload files and give them titles
    Then I should see that the news article has attachments

  Scenario: Keep existing attachments
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files including an existing file
    And I select keep file for existing file
    And I save the files
    Then I should see that the news article has the new attachment and the existing attachment

  Scenario: Keep existing attachments without new file name
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files including an existing file
    And I select keep file for existing file
    And I do not enter a new file name
    And I save the files
    Then I should see an error of "Attachment data new filename cannot be blank" on the bulk upload page

  Scenario: Keep existing attachments with same file name
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files including an existing file
    And I select keep file for existing file
    And I enter the same name as the existing file
    And I save the files
    Then I should see an error of "File with name "greenpaper.pdf" already attached to document" on the bulk upload page    

  Scenario: Replacing existing attachments
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files including an existing file
    And I change the title and select replace for the existing file
    And I save the files
    Then I should see that the news article has the existing attachment with updated title and the new attachment

  Scenario: Cancel upload of existing attachments
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files including an existing file
    And I change the title and select reject for the existing file
    And I save the files
    Then I should see that the news article has the existing attachment with original title and the new attachment
