Feature: Reviewing publications

Scenario: Viewing a publication that's been submitted for review with a PDF attachment
  Given a submitted publication "Legalise beards" with a PDF attachment
  And I am an editor
  When I visit the list of documents awaiting review
  And I view the publication "Legalise beards"
  And I should see a link to the PDF attachment
