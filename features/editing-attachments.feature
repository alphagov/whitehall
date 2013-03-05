Feature: Editing attachments
  In order to send the best version of a policy to the departmental editor
  A writer
  Should be able to manipulate the attachments on a document

  Background:
    Given I am a writer

  Scenario: Removing an attachment
    Given a draft publication "Legalise beards" with a PDF attachment
    When I remove the attachment from the publication "Legalise beards"
    And I visit the list of draft documents
    And I view the publication "Legalise beards"
    Then I should not see a link to the PDF attachment

  Scenario: Preserving attachments on published documents
    Given a published publication "Standard Beard Lengths" with a PDF attachment
    When I remove the attachment from a new draft of the publication "Standard Beard Lengths"
    And I visit the publication "Standard Beard Lengths"
    Then I should see a link to the PDF attachment

  Scenario: Remember uploaded file after validation failure
    Given I attempt to create an invalid publication with an attachment
    When I correct the invalid information for the publication
    Then I should see a link to the PDF attachment

  @quarantine-files
  Scenario: Attachments are virus-checked before publication
    Given a published publication "Legalise beards" with a PDF attachment
    When I visit the publication "Legalise beards"
    Then I should see a placeholder thumbnail whilst the attachment is being virus checked
    Then clicking on the attachment redirects me to an explanatory page

  @quarantine-files
  Scenario: Attachments are viewable after being virus-checked
    Given a published publication "Legalise beards" with a PDF attachment
    And the attachment has been virus-checked
    And I visit the publication "Legalise beards"
    Then I can see the attachment thumbnail and download it

  Scenario: Updating new edition does not change metadata
    Given a published publication "Standard Beard Lengths" with a PDF attachment
    When I update the attachment metadata from a new draft of the publication
    Then the metadata changes should not be public until the draft is published

  @quarantine-files
  Scenario: Replacing data on an attachment
    Given I am an editor
    And a published publication "Standard Beard Lengths" with a PDF attachment
    And the attachment has been virus-checked
    When I replace the data file of the attachment in a new draft of the publication
    And the attachment has been virus-checked
    Then the new data file should not be public until the draft is published
    When I log out
    Then the old data file should redirect to the new data file
