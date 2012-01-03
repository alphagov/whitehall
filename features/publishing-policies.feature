Feature: Publishing policies
  In order to allow the public to view policies
  A departmental editor
  Should be able to publish policies

Background:
  Given I am an editor

Scenario: Publishing a submitted publication
  Given a submitted policy "Ban Beards" exists
  When I publish the policy "Ban Beards"
  Then I should see the policy "Ban Beards" in the list of published documents
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