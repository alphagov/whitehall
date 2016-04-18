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

  Scenario: Policy groups appear in the public index
    Given a policy group "ABC Advisories" exists
    When I visit the policy group index
    Then I should see the policy group "ABC Advisories" in the index

  Scenario:
    Given a policy group "Panel" exists
    Then I should be able to add attachments to the policy group "Panel"

  Scenario: Deleting a policy group
    Given I am a GDS editor
    And a policy group "Delete me" exists
    When I delete the policy group "Delete me"
    Then I should not see the policy group "Delete me"
