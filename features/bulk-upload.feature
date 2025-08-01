@disable-sidekiq-test-mode
Feature: Bulk uploading attachments to editions

  Background:
    Given I am a writer

  Scenario: Uploading mulitple attachments
    Given a draft news article "Stubble to be Outlawed" exists
    When I bulk upload files and give them titles
    Then I should see that the news article has attachments

  Scenario: Replacing existing attachments
    Given a draft publication "Results of beards survey" with a file attachment exists
    When I bulk upload files including the file "greenpaper.pdf"
    Then the greenpaper.pdf attachment file should be replaced with the new file
    And any other files should be added as new attachments
