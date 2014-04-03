Feature: Policy groups
  As a citizen:

  I want to be able to follow a link from policy documents to the profile of any groups who are influencing the policy
  So I can see how outside experts and stakeholders are involved in making the policy

  Done means:

  - It is possible to create 'Policy groups' and associate them to policies
  - multiple policy groups can be associated to a single policy
  - doing so results in a line of metadata on the policy page, below the one for a policy team, which reads "Groups: [Title of group as a link]" with the +others JavaScript behaviour for multiple items.
  - An group page comprises:
    - Title
    - Summary
    - Description (markdown field)
    - Contact email
    - Attachments (placed inline using markdown)
  - consistent with the policy teams design, the H2s are pulled out into a contents list as anchor links

  Background:
    Given I am an editor

  Scenario: Associate a policy group to a policy
    Given a policy group "PolGroup Inc." exists
    And a draft policy "Policy of things" exists
    When I associate the policy group "PolGroup Inc." with the policy "Policy of things"
    And I force publish the policy "Policy of things"
    And I visit the policy "Policy of things"
    Then I should see a link to the policy group "PolGroup Inc."

  Scenario: Associate multiple policy groups to a policy
    Given a policy group "PolGroup Inc." exists
    And a policy group "Acme Policies Ltd" exists
    And a draft policy "Policy of all the stuff" exists
    When I associate the policy groups "PolGroup Inc." and "Acme Policies Ltd" with the policy "Policy of all the stuff"
    And I force publish the policy "Policy of all the stuff"
    And I visit the policy "Policy of all the stuff"
    Then I should see a link to the policy group "Acme Policies Ltd"
    And I should see a link to the policy group "PolGroup Inc."

  Scenario: Policy groups have their own page
    Given a policy group "ABC Advisories" exists
    When I visit the policy group "ABC Advisories"
    Then I should see the policy group "ABC Advisories"

  Scenario:
    Given a policy group "Panel" exists
    Then I should be able to add attachments to the policy group "Panel"

  Scenario: Deleting a policy group
    Given I am a GDS editor
    And a policy group "Delete me" exists
    When I delete the policy group "Delete me"
    Then I should not see the policy group "Delete me"
