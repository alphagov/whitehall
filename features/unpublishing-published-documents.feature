Feature: Unpublishing published documents
  As a GDS Editor
  I want to be able to revert published documents back to the draft state
  So that I can remove documents from the site that were published in error

  @not-quite-as-fake-search
  Scenario: Unpublishing a published document
    Given I am a GDS editor
    And a published document "Published by accident" exists
    When I unpublish the document because it was published in error
    Then there should be an editorial remark recording the fact that the document was unpublished
    And I should see that the document was published in error on the public site
    And the policy "Published by accident" should no longer be listed on the public site

  Scenario: Unpublishing a document that has had a title change
    Given I am a GDS editor
    And a published document exists with a slug that does not match the title
    When I unpublish the document because it was published in error
    Then I should see that the document was published in error at the original url

  Scenario: Unpublishing a document and redirecting
    Given I am a GDS editor
    And a published document "Published by accident" exists
    When I unpublish the document and ask for a redirect
    Then I should be redirected to the new url when I view the document on the public site

  Scenario: Consolidating a document into another GOV.UK page
    Given I am a GDS editor
    And there is a published document that is a duplicate of another page
    When I unpublish the duplicate, marking it as consolidated into the other page
    Then I should be redirected to the other page when I view the document on the public site
