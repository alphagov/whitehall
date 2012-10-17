Feature: Publishing consultations

Scenario: Publishing a submitted consultation
  Given I am an editor
  And a submitted consultation "Beard Length Review" exists
  When I publish the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of published documents
  And the consultation "Beard Length Review" should be visible to the public

Scenario: Adding a response to a consultation
  Given I am an editor
  And a published consultation "Beard Length Review" exists
  When I add a response to the consultation
  And I save and publish the amended consultation
  Then the consultation response should be viewable

Scenario: Specifying published date of consultation
  Given I am an editor
  And a published consultation "Beard Length Review" exists
  When I add a response to the consultation
  And I specify the published response date of the consultation
  Then the published date should be visible on save

