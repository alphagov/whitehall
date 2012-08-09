Feature: Administering Organisations

Scenario: Featuring news on an organisation page
  Given the organisation "Ministry of Pop" exists
  And a published news article "You must buy the X-Factor single, says Queen" was produced by the "Ministry of Pop" organisation
  And a published news article "Simon Cowell to receive dubious honour" was produced by the "Ministry of Pop" organisation
  And a published news article "Bringing back the Charleston" was produced by the "Ministry of Pop" organisation

  When I set the featured news articles in the "Ministry of Pop" organisation to:
    |News Article|
    |Bringing back the Charleston|
    |You must buy the X-Factor single, says Queen|
  And I order the featured items in the "Ministry of Pop" organisation as:
    |News Article|
    |You must buy the X-Factor single, says Queen|
    |Bringing back the Charleston|
  Then I should see the featured news articles in the "Ministry of Pop" organisation are:
    |You must buy the X-Factor single, says Queen|
    |Bringing back the Charleston|

Scenario: Requesting publications in alternative format
  Given I am an admin called "Jane"
  And the organisation "Ministry of Pop" exists
  And I set the alternative format contact email of "Ministry of Pop" to "alternative.format@ministry-of-pop.gov.uk"
  And a published publication "Charleston styles today" with a PDF attachment and alternative format provider "Ministry of Pop"
  When I visit the publication "Charleston styles today"
  Then I should see a mailto link for the alternative format contact email "alternative.format@ministry-of-pop.gov.uk"
