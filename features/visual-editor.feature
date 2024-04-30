Feature: Save edition content with visual editor
  Background:
    Given I am a GDS editor in the organisation "Visual ministry"
    And The visual editor private beta feature flag is enabled
    And I have the "Visual editor private beta" permission

  @javascript
  Scenario: I create a new publication
    When I start creating a new publication
    Then I should see the visual editor instead of the govspeak editor
    When I fill in the required fields for publication "Publication with visual editor" in organisation "Visual ministry"
    And I save and go to document summary
    Then I see the visual editor on subsequent edits of the publication
    And I force publish the publication "Publication with visual editor"
    
  @javascript
  Scenario: I create a new HTML attachment
    When I start creating a new HTML attachment for a publication
    Then I should see the visual editor instead of the govspeak editor

  @javascript
  Scenario: I edit an existing HTML attachment
    Given a draft publication with an HTML attachment "HTML Attachment with visual editor" exists
    When I edit the HTML attachment "HTML Attachment with visual editor"
    Then I should see the visual editor instead of the govspeak editor
