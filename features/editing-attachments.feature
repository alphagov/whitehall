Feature: Editing attachments
In order to send the best version of a policy to the departmental editor
A writer
Should be able to manipulate the attachments on a document

Background:
  Given I am a writer

Scenario: Removing an attachment
  Given a draft publication "Legalise beards" with a PDF attachment "something.pdf"
  When I remove the attachment "something.pdf" from the publication "Legalise beards"
  And I visit the list of draft documents
  And I view the publication "Legalise beards"
  Then I should not see a link to the PDF attachment "something.pdf"

Scenario: Preserving attachments on published documents
  Given a published publication "Standard Beard Lengths" with a PDF attachment "something.pdf"
  When I remove the attachment "something.pdf" from a new draft of the publication "Standard Beard Lengths"
  And I visit the publication "Standard Beard Lengths"
  Then I should see a link to the PDF attachment "something.pdf"

Scenario: Remember uploaded file after validation failure
  Given I attempt to create an invalid publication with a attachment "something.pdf"
  When I set the publication title to "Validation Error Fixed" and save
  Then I should see a link to the PDF attachment "something.pdf"
  