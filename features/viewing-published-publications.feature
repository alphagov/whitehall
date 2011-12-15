Feature: Viewing published publications

Scenario: Viewing published publications
  Given a published publication "Lamb chops on baker's faces" exists
  When I visit the list of publications
  Then I should see the publication "Lamb chops on baker's faces"
  And I should see the summary of the publication "Lamb chops on baker's faces"

Scenario: Publishing a publication that has a PDF attachment
  Given a published publication "Standard Beard Lengths" with a PDF attachment
  When I visit the publication "Standard Beard Lengths"
  Then I should see a link to the PDF attachment
  And I should see a thumbnail of the first page of the PDF