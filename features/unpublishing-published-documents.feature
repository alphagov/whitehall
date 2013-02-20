Feature: Unpublishing published documents
  As a GDS Editor
  I want to be able to revert published documents back to the draft state
  So that I can remove documents from the site that were published in error

  Scenario: Unpublishing a published document
    Given I am a GDS editor
    And a published document "Published by accident" exists
    When I unpublish the document because it was published in error
    Then I should see that the document was published in error on the public site

  Scenario: Unpublishing a document that has had a title change
    Given I am a super user
    And a published policy "Published by accident" exists
    When I visit the public url "/government/policies/published-by-accident"
    Then I should see the document
    When I republish it with the new title "This document no longer exists"
    And  I visit the public url "/government/policies/published-by-accident"
    Then I should still see the document
    When I unpublish the document because it was published in error
    And  I visit the public url "/government/policies/published-by-accident"
    Then I should see that the document was published in error
