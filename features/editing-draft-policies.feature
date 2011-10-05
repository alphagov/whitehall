Feature: Editing draft policies
In order to send the best version of a policy to the departmental editor
A writer
Should be able to edit and save draft policies

Scenario: Creating a new draft policy
  Given I am a writer
  When I draft a new policy "Outlaw Moustaches"
  Then I should see the policy "Outlaw Moustaches" in the list of draft documents

Scenario: Creating a new draft policy in multiple topics
  Given I am a writer
  And two topics "Facial Hair" and "Hirsuteness" exist
  When I draft a new policy "Outlaw Moustaches" in the "Facial Hair" and "Hirsuteness" topics
  Then the policy "Outlaw Moustaches" should be in the "Facial Hair" and "Hirsuteness" topics

Scenario: Submitting a draft policy to a second pair of eyes
  Given I am a writer
  And a draft policy called "Outlaw Moustaches" exists
  When I submit the policy "Outlaw Moustaches"
  Then I should see the policy "Outlaw Moustaches" in the list of submitted documents

Scenario: Editing an existing draft policy
  Given I am a writer
  And a draft policy called "Outlaw Moustaches" exists
  When I edit the policy "Outlaw Moustaches" changing the title to "Ban Moustaches"
  Then I should see the policy "Ban Moustaches" in the list of draft documents

Scenario: Trying to save a policy that has been changed by another user
  Given I am a writer
  And a draft policy called "Outlaw Moustaches" exists
  And I start editing the policy "Outlaw Moustaches" changing the title to "Ban Moustaches"
  And another user edits the policy "Outlaw Moustaches" changing the title to "Ban Beards"
  When I save my changes to the policy
  Then I should see the conflict between the policy titles "Ban Moustaches" and "Ban Beards"
  When I edit the policy changing the title to "Ban Moustaches and Beards"
  Then I should see the policy "Ban Moustaches and Beards" in the list of draft documents
