Feature: Consultations

Scenario: Creating a new draft consultation
  Given I am a writer
  And I have the "Preview design system" permission
  When I draft a new "English" language consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of draft documents

Scenario: Submitting a draft consultation to a second pair of eyes
  Given I am a writer
  And I have the "Preview design system" permission
  And a draft consultation "Beard Length Review" exists
  When I submit the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of submitted documents

@not-quite-as-fake-search
Scenario: Publishing a submitted consultation
  Given I am an editor
  And I have the "Preview design system" permission
  And a submitted consultation "Beard Length Review" exists
  When I check "Beard Length Review" adheres to the consultation principles
  And I publish the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of published documents

@disable-sidekiq-test-mode
Scenario: Adding an outcome to a closed consultation
  Given I am an editor
  And I have the "Preview design system" permission
  And a closed consultation exists
  When I add an outcome to the consultation
  And I save and publish the amended consultation
  Then I can see that the consultation has been published

@disable-sidekiq-test-mode
Scenario: Adding public feedback to a closed consultation
  Given I am an editor
  And I have the "Preview design system" permission
  And a closed consultation exists
  When I add public feedback to the consultation
  And I save and publish the amended consultation
  Then I can see that the consultation has been published

@javascript
Scenario: Associating an offsite consultation with topical events
  Given I am an editor
  And I have the "Preview design system" permission
  And a draft consultation "Beard Length Review" exists
  When I am on the edit page for consultation "Beard Length Review"
  And I mark the consultation as offsite
  Then the consultation can be associated with topical events

@javascript
Scenario: Creating a new draft consultation in another language
  Given I am a writer
  And I have the "Preview design system" permission
  When I draft a new "Cymraeg" language consultation "Beard Length Review"
  Then I can see the primary locale for consultation "Beard Length Review" is "cy"
