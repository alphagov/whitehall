Feature: Managing supporting pages for policies
  As an editor
  I want to be able to create supporting pages and associate them with policies
  In order to provide more detailed information about the policy

Background:
  Given I am a managing editor

Scenario: Adding a supporting page to a published policy
  Given a published policy "Outlaw Moustaches" exists
  When I add a supporting page "Handlebar Waxing" to the "Outlaw Moustaches" policy
  And I force publish the supporting page "Handlebar Waxing"
  Then I should see on the published policy page that "Outlaw Moustaches" has supporting page "Handlebar Waxing"
  And I should see in the admin list of published documents that "Outlaw Moustaches" has supporting page "Handlebar Waxing"

Scenario: Adding a supporting page to a draft policy
  Given a draft policy "Outlaw Moustaches" exists
  When I add a supporting page "Handlebar Waxing" to the "Outlaw Moustaches" policy
  And I force publish the supporting page "Handlebar Waxing"
  Then I should see on the preview policy page that "Outlaw Moustaches" has supporting page "Handlebar Waxing"
  And I should see in the admin list of draft documents that "Outlaw Moustaches" has supporting page "Handlebar Waxing"

Scenario: Unpublishing a supporting page
  Given a published supporting page exists
  When I unpublish the document and ask for a redirect
  Then I should be redirected to the new url when I view the document on the public site
