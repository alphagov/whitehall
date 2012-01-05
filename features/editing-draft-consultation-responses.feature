Feature: Editing consultation responses

Scenario: Drafting a new consultation response
  Given I am a writer
  And a published consultation "Beard Length Review" exists
  When I draft a new consultation response "Tide of opinion against stubble" to the consultation "Beard Length Review"
  Then I should see the consultation response "Tide of opinion against stubble" in the list of draft documents
