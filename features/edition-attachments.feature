@disable-sidekiq-test-mode
Feature: Managing attachments on editions
  As a writer or editor
  I want to attach files and additional HTML content to publications and consultations
  In order to support the publications and consultations with statistics and other relevant documents

  Scenario: Adding and reordering attachments
    Given I am an writer
    And I start drafting a new publication "Standard Beard Lengths"
    When I start editing the attachments from the publication page
    And I upload a file attachment with the title "Beard Length Statistics 2014" and the file "dft_statistical_data_set_sample.csv"
    And I upload an html attachment with the title "Beard Length Graphs 2012" and the body "Example **Govspeak body**"
    And I add an external attachment with the title "Beard Length Illustrations" and the URL "http://www.beardlengths.gov.uk"
    Then the publication "Standard Beard Lengths" should have 3 attachments
    When I set the order of attachments to:
      | title                        | order |
      | Beard Length Graphs 2012     | 0     |
      | Beard Length Statistics 2014 | 1     |
      | Beard Length Illustrations   | 2     |
    Then the attachments should be in the following order:
      | title                        |
      | Beard Length Graphs 2012     |
      | Beard Length Statistics 2014 |
      | Beard Length Illustrations   |

  Scenario: Previewing HTML attachment
    Given I am an writer
    And I start drafting a new publication "Standard Beard Lengths"
    When I start editing the attachments from the publication page
    And I begin editing an html attachment with the title "Beard Length Graphs 2012" and the body "Example text"
    Then I cannot see a preview link
    When I save the attachment
    Then I can see the attachment title "Beard Length Graphs 2012"
    And I can see the preview link to the attachment "HTML attachment"
    When I edit the attachment
    Then I can see a preview link

  Scenario: Previewing HTML attachment on consultation responses
    Given I am a writer
    And a draft closed consultation "Should We Ban Beards" with an outcome exists
    When I go to the outcome for the consultation "Should We Ban Beards"
    And I begin editing an html attachment with the title "Beard Length Graphs 2012" and the body "Example text"
    Then I cannot see a preview link
    When I save the attachment
    Then I can see the attachment title "Beard Length Graphs 2012"
    And I can see the preview link to the attachment "HTML attachment"
    When I edit the attachment
    Then I can see a preview link


  Scenario: Adding attachments on consultation responses
    Given I am a writer
    And a draft closed consultation "Should We Ban Beards" with an outcome exists
    When I go to the outcome for the consultation "Should We Ban Beards"
    And I upload a file attachment with the title "Beard Length Statistics 2014" and the file "dft_statistical_data_set_sample.csv"
    Then the outcome for the consultation should have the attachment "Beard Length Statistics 2014"

  Scenario: Attempting to save attachment after validation failure
    Given I am a writer
    And a draft publication "Standards on Beard Grooming" exists
    When I try and upload an attachment but there are validation errors
    Then I should be able to submit the attachment without re-uploading the file

  Scenario: Attempting to publish attachment which is still being uploaded to the asset manager
    Given I am an editor
    And a published publication "Standard Beard Lengths" with a PDF attachment
    And the attachment has been uploaded to the asset-manager
    When I replace the data file of the attachment in a new draft of the publication
    And I try to publish the draft edition
    Then I see a validation error for uploading attachments

  Scenario: Editing metadata on attachments
    Given I am an writer
    And I start drafting a new publication "Standard Beard Lengths"
    When I start editing the attachments from the publication page
    And I upload an html attachment with the title "Beard Length Graphs 2012" and the isbn "9781474127783"
    And I publish the draft edition for publication "Standard Beard Lengths"
    Then the html attachment "Beard Length Graphs 2012" includes the isbn "9781474127783"
