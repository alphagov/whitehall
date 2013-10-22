Feature: Managing attachments on editions
  As a writer or editor
  I want to attach files and additional HTML content to publications and consultations
  In order to support the publications and consultations with statistics and other relevant documents

  Scenario: Adding and reordering attachments
    Given I am an writer
    And I draft a new publication "Standard Beard Lengths"
    When I start editing the attachments from the publication page
    And I upload a file attachment with the title "Beard Length Statistics 2014" and the file "dft_statistical_data_set_sample.csv"
    And I upload an html attachment with the title "Beard Length Graphs 2012" and the body "Example **Govspeak body**"
    Then the publication "Standard Beard Lengths" should have 2 attachments

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
