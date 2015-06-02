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
    And I should see that the document was published in error on the public site
    And the publication "Published by accident" should no longer be listed on the public site

  Scenario: Unpublishing a document that has had a title change
    Given I am a managing editor
    And a published document exists with a slug that does not match the title
    When I unpublish the document because it was published in error
    Then I should see that the document was published in error at the original url

  Scenario: Draft resulting from an unpublishing should not be deletable
    Given I am a managing editor
    And a published document exists with a slug that does not match the title
    When I unpublish the document because it was published in error
    Then I should not be able to discard the draft resulting from the unpublishing

  Scenario: Unpublishing a document and redirecting
    Given I am a managing editor
    And a published document "Published by accident" exists
    When I unpublish the document and ask for a redirect
    Then I should be redirected to the new url when I view the document on the public site

  Scenario: Consolidating a document into another GOV.UK page
    Given I am a managing editor
    And there is a published document that is a duplicate of another page
    When I unpublish the duplicate, marking it as consolidated into the other page
    Then I should be redirected to the other page when I view the document on the public site

  Scenario: Withdraw a document that is no longer current
    Given I am a managing editor
    And a published publication "Shaving kits for all" exists
    When I withdraw the publication because it is no longer government publication
    Then there should be an editorial remark recording the fact that the document was withdrawn
    And the publication should be marked as withdrawn on the public site

  Scenario: Change the public explanation for archiving a document
    Given I am a managing editor
    And a published publication "Shaving kits for all" exists
    And I withdraw the publication because it is no longer government publication
    When I edit the public explanation for withdrawal
    Then I should see the updated explanation on the public site
