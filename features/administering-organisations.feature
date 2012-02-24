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
  Then I should see the featured news articles in the "Ministry of Pop" organisation are:
    |Bringing back the Charleston|
    |You must buy the X-Factor single, says Queen|
