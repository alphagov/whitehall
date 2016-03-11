Feature: Unpublishing published documents
  As a Managing Editor
  I can unwithdraw unwithdrawn documents
  So that I can adjust them with banners or annotations and withdraw them again

  Scenario: Unwithdrawing a withdrawn document
    Given I am a managing editor
    And a published publication "Shaving kits for all" exists
    When I withdraw the publication because it no longer reflects current government policy
    And I unwithdraw the publication
    Then I should be redirected to the latest edition of the publication
    And the unwithdrawn publication is accessible on the website
