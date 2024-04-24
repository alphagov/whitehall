Feature: Save edition content with visual editor
  Background:
    Given I am a writer
    And The visual editor private beta feature flag is enabled
    And I have the "Visual editor private beta" permission

  @javascript
  Scenario: I create a new publication
    When I start creating a new publication
    Then I should see the visual editor instead of the govspeak editor

  @javascript
  Scenario: I edit an existing publication
    Given a draft publication "Publication with visual editor" exists
    When I am on the edit page for publication "Publication with visual editor"
    Then I should see the visual editor instead of the govspeak editor

  @javascript
  Scenario: I create a new HTML attachment
    When I start creating a new HTML attachment for a publication
    Then I should see the visual editor instead of the govspeak editor

  @javascript
  Scenario: I edit an existing HTML attachment
    Given a draft publication with an HTML attachment "HTML Attachment with visual editor" exists
    When I edit the HTML attachment "HTML Attachment with visual editor"
    Then I should see the visual editor instead of the govspeak editor
