Feature: Publishing policies
  In order to allow the public to view policies
  A departmental editor
  Should be able to publish policies

Background:
  Given I am an editor

Scenario: Publishing a submitted publication
  Given a submitted policy "Ban Beards" exists
  When I publish the policy "Ban Beards"
  Then my attempt to publish "Ban Beards" should succeed
  And I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public

Scenario: Trying to publish a policy that has been changed by another user
  Given a submitted policy "Ban Beards" exists
  When I publish the policy "Ban Beards" but another user edits it while I am viewing it
  Then my attempt to publish "Ban Beards" should fail

Scenario: Maintain existing relationships
  Given a published news article "Government to reduce hirsuteness" with related published policies "Ban Beards" and "Unimportant"
  When I publish a new edition of the policy "Ban Beards" with the new title "Ban Facial Hair"
  And I visit the news article "Government to reduce hirsuteness"
  Then I can see links to the related published policies "Ban Facial Hair" and "Unimportant"

Scenario: Publishing a first edition without a change note
  Given a submitted policy "Ban Beards" exists
  When I publish the policy "Ban Beards" without a change note
  Then my attempt to publish "Ban Beards" should succeed
  And I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public

Scenario: Publishing a subsequent edition without a change note
  Given a published policy "Ban Beards" exists
  When I publish a new edition of the policy "Ban Beards" without a change note
  Then my attempt to publish "Ban Beards" should fail

Scenario: Publishing a subsequent edition as a minor edit
  Given a published policy "Ban Beards" exists
  When I publish a new edition of the policy "Ban Beards" as a minor change
  Then my attempt to publish "Ban Beards" should succeed

Scenario: Publishing a subsequent edition with a change note
  Given a published policy "Ban Beards" exists
  When I publish a new edition of the policy "Ban Beards" with a change note "Exempted Santa Claus"
  Then my attempt to publish "Ban Beards" should succeed
  And I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public
  And the change note "Exempted Santa Claus" should appear in the history for the policy "Ban Beards"

Scenario: Viewing policy publishing history
  Given a published policy "Ban Beards" exists
  When I publish a new edition of the policy "Ban Beards" with a change note "Exempted Santa Claus"
  And I publish a new edition of the policy "Ban Beards" with a change note "Exempted Gimli son of Gloin"
  Then the policy "Ban Beards" should be visible to the public
  And the change note "Exempted Santa Claus" should appear in the history for the policy "Ban Beards"
  And the change note "Exempted Gimli son of Gloin" should appear in the history for the policy "Ban Beards"

