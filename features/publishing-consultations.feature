Feature: Publishing consultations

Scenario: Publishing a submitted consultation
  Given I am an editor
  And a submitted consultation "Beard Length Review" exists
  When I publish the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of published documents
  And the consultation "Beard Length Review" should be visible to the public