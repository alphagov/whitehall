Feature: Publishing policies
  In order to allow the public to view policies
  A departmental editor
  Should be able to publish policies

Scenario: Publishing a submitted publication
  Given I am an editor
  And a submitted policy called "Ban Beards" exists
  When I publish the policy "Ban Beards"
  Then I should see the policy "Ban Beards" in the list of published documents
  And the policy "Ban Beards" should be visible to the public

Scenario: Trying to publish a policy that has been changed by another user
  Given I am an editor
  And a submitted policy called "Ban Beards" exists
  When I publish the policy "Ban Beards" but another user edits it while I am viewing it
  Then my attempt to publish "Ban Beards" should fail
