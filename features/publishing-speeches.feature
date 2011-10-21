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
