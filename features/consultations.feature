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

Scenario: Creating a consultation related to multiple worldwide prioirites
  Given a published worldwide priority "Fish Exchange Programme" exists
  And a published worldwide priority "Supporting British Fish Abroad" exists
  When I draft a new consultation "Fishy Business" relating it to the worldwide_priorities "Fish Exchange Programme" and "Supporting British Fish Abroad"
  Then I should see in the preview that "Fishy Business" should related to "Fish Exchange Programme" and "Supporting British Fish Abroad" worldwide priorities

@not-quite-as-fake-search
Scenario: Publishing a submitted consultation
  Given I am an editor
  And a submitted consultation "Beard Length Review" exists
  When I publish the consultation "Beard Length Review"
  Then I should see the consultation "Beard Length Review" in the list of published documents
  And the consultation "Beard Length Review" should be visible to the public

Scenario: Adding a response to a closed consultation
  Given I am an editor
  And a closed consultation exists
  When I add a response to the consultation
  And I save and publish the amended consultation
  Then the consultation response should be viewable

Scenario: Specifying published date of consultation
  Given I am an editor
  And a published consultation "Beard Length Review" exists
  When I add a response to the consultation
  And I specify the published response date of the consultation
  Then the published date should be visible on save

