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
      |         title                | order |
      | Beard Length Graphs 2012     |   0   |
      | Beard Length Statistics 2014 |   1   |
      | Beard Length Illustrations   |   2   |
    Then the attachments should be in the following order:
      |         title                |
      | Beard Length Graphs 2012     |
      | Beard Length Statistics 2014 |
      | Beard Length Illustrations   |

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

  Scenario: Adding attachments on consultation responses
    Given I am a writer
    And a draft closed consultation "Should We Ban Beards" with an outcome exists
    When I go to the outcome for the consultation "Should We Ban Beards"
    And I upload a file attachment with the title "Beard Length Statistics 2014" and the file "dft_statistical_data_set_sample.csv"
    Then the outcome for the consultation should have the attachment "Beard Length Statistics 2014"

  Scenario: Previewing HTML attachments on draft publication
    Given I am a writer
    And a draft publication "Standard Beard Lengths" exists
    And the publication "Standard Beard Lengths" has an html attachment "Beard Length Graphs 2012" with the body "Example Govspeak body"

  Scenario: Attempting to save attachment after validation failure
    Given I am a writer
    And a draft publication "Standards on Beard Grooming" exists
    When I try and upload an attachment but there are validation errors
    Then I should be able to submit the attachment without re-uploading the file

