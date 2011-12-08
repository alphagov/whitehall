Feature: Publishing speeches

Scenario: Publishing a submitted speech
  Given I am an editor
  And a submitted speech "Stubble to be Outlawed" exists
  When I publish the speech "Stubble to be Outlawed"
  Then I should see the speech "Stubble to be Outlawed" in the list of published documents
  And the speech "Stubble to be Outlawed" should be visible to the public