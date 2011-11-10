Feature: Publishing speeches

Scenario: Creating a new draft speech
  Given I am a writer
  When I draft a new speech "Stubble to be Outlawed"
  Then I should see the speech "Stubble to be Outlawed" in the list of draft documents

Scenario: Submitting a draft publication to a second pair of eyes
  Given I am a writer
  And a draft speech "Stubble to be Outlawed" exists
  When I submit the speech "Stubble to be Outlawed"
  Then I should see the speech "Stubble to be Outlawed" in the list of submitted documents

Scenario: Publishing a submitted publication
  Given I am an editor
  And a submitted speech "Stubble to be Outlawed" exists
  When I publish the speech "Stubble to be Outlawed"
  Then I should see the speech "Stubble to be Outlawed" in the list of published documents
  And the speech "Stubble to be Outlawed" should be visible to the public

Scenario: Creating a speech related to multiple policies
  Given I am a writer
  And two published policies "Against All Cods" and "O For Tuna" exist
  When I draft a new speech "Fishy Business" relating it to "Against All Cods" and "O For Tuna"
  Then I should see in the preview that "Fishy Business" should related to "Against All Cods" and "O For Tuna" policies
