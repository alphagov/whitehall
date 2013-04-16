Feature: Policy advisory groups
  As a citizen:

  I want to be able to follow a link from policy documents to the profile of any advisory groups who are influencing the policy
  So I can see how outside experts and stakeholders are involved in making the policy

  Done means:

  - It is possible to create 'Policy advisory groups' and associate them to policies
  - multiple policy advisory groups can be associated to a single policy
  - doing so results in a line of metadata on the policy page, below the one for a policy team, which reads "Advisory groups: [Title of advisory group as a link]" with the +others JavaScript behaviour for multiple items.
  - An advisory group page comprises:
    - Title
    - Summary
    - Description (markdown field)
    - Contact email
    - Attachments (placed inline using markdown)
  - consistent with the policy teams design, the H2s are pulled out into a contents list as anchor links

  Background:
    Given I am an editor

  Scenario: Associate a policy advisory group to a policy
    Given a policy advisory group "PolGroup Inc." exists
    And a draft policy "Policy of things" exists
    When I associate the policy advisory group "PolGroup Inc." with the policy "Policy of things"
    And I force publish the policy "Policy of things"
    And I visit the policy "Policy of things"
    Then I should see the policy advisory group "PolGroup Inc."

  Scenario: Associate multiple policy advisory groups to a policy
    Given a policy advisory group "PolGroup Inc." exists
    And a policy advisory group "Acme Policies Ltd" exists
    And a draft policy "Policy of all the stuff" exists
    When I associate the policy advisory groups "PolGroup Inc." and "Acme Policies Ltd" with the policy "Policy of all the stuff"
    And I force publish the policy "Policy of all the stuff"
    And I visit the policy "Policy of all the stuff"
    Then I should see the policy advisory group "Acme Policies Ltd"
    And I should see the policy advisory group "PolGroup Inc."

  Scenario: Policy advisory groups have their own page
    Given a policy advisory group "ABC Advisories" exists
    When I visit the policy advisory group "ABC Advisories"
    Then I should see the policy advisory group "ABC Advisories"

  Scenario: Attachments can be added to policy advisory groups using Markdown
    Given a policy advisory group "Yet More Amazing Advisories" exists
    And I attach a PDF document "Meeting notes" to the policy advisory group "Yet More Amazing Advisories"
    When I insert the attachment into the body of policy advisory group "Yet More Amazing Advisories"
    And I visit the policy advisory group "Yet More Amazing Advisories"
    Then I should be able to see a PDF document "Meeting notes"

  Scenario: Deleting a policy advisory group
    Given I am a GDS editor
    And a policy advisory group "Delete me" exists
    When I delete the policy advisory group "Delete me"
    Then I should not see the policy advisory group "Delete me"
