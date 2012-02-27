Feature: Publishing consultation responses

Scenario: Publishing a submitted consultation
  Given I am an editor
  And a published closed consultation "Beard Length Review" exists
  And a submitted consultation response "Tide of opinion against stubble" to the consultation "Beard Length Review" exists
  When I publish the consultation response "Tide of opinion against stubble"
  Then I should see the consultation response "Tide of opinion against stubble" in the list of published documents
  And the consultation "Beard Length Review" should show the response "Tide of opinion against stubble"
