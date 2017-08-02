Feature: Unpublishing published documents
  As a GDS Editor
  I want to be able to revert published documents back to the draft state
  So that I can remove documents from the site that were published in error

  @not-quite-as-fake-search
  Scenario: Unpublishing a published document
    Given I am a managing editor
    And a published document "Published by accident" exists
    When I unpublish the document because it was published in error
    Then there should be an editorial remark recording the fact that the document was unpublished
    And there should be an unpublishing explanation of "This page should never have existed" and a reason of "Published in error"

  Scenario: Draft resulting from an unpublishing should not be deletable
    Given I am a managing editor
    And a published document exists with a slug that does not match the title
    When I unpublish the document because it was published in error
    Then I should not be able to discard the draft resulting from the unpublishing

  Scenario: Unpublishing a document and redirecting
    Given I am a managing editor
    And a published document "Published by accident" exists
    When I unpublish the document and ask for a redirect to "https://www.test.gov.uk/example"
    Then the unpublishing should redirect to "https://www.test.gov.uk/example"

  Scenario: Consolidating a document into another GOV.UK page
    Given I am a managing editor
    And there is a published document that is a duplicate of another page
    When I unpublish the duplicate, marking it as consolidated into the other page
    Then the unpublishing should redirect to the existing edition

  Scenario: Withdraw a document that is no longer current
    Given I am a managing editor
    And a published publication "Shaving kits for all" exists
    When I withdraw the publication with the explanation "Policy change"
    Then there should be an unpublishing explanation of "Policy change" and a reason of "No longer current government policy/activity"

  Scenario: Change the public explanation for archiving a document
    Given I am a managing editor
    And a published publication "Shaving kits for all" exists
    When I withdraw the publication with the explanation "Policy change"
    When I edit the public explanation for withdrawal to "The policy has changed"
    Then there should be an unpublishing explanation of "The policy has changed" and a reason of "No longer current government policy/activity"
