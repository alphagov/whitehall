Feature: Consultations

Scenario: Creating a new draft consultation
  Given I am a writer
  When I draft a new consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of draft documents

Scenario: Submitting a draft consultation to a second pair of eyes
  Given I am a writer
  And a draft consultation "Beard Length Review" exists
  When I submit the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of submitted documents

@not-quite-as-fake-search
Scenario: Publishing a submitted consultation
  Given I am an editor
  And a submitted consultation "Beard Length Review" exists
  When I publish the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of published documents

Scenario: Viewing an unopened consultation
  Given I am an editor
  And an unopened consultation exists
  When I visit the consultation
  Then the date the consultation opens should be viewable

Scenario: Adding an outcome to a closed consultation
  Given I am an editor
  And a closed consultation exists
  When I add an outcome to the consultation
  And I save and publish the amended consultation
  Then the consultation outcome should be viewable

Scenario: Adding public feedback to a closed consultation
  Given I am an editor
  And a closed consultation exists
  When I add public feedback to the consultation
  And I save and publish the amended consultation
  Then the public feedback should be viewable

@javascript
Scenario: Associating an offsite consultation with topical events
  Given I am an editor
  And a draft consultation "Beard Length Review" exists
  When I am on the edit page for consultation "Beard Length Review"
  And I mark the consultation as offsite
  Then the consultation can be associated with topical events
