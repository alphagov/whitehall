Feature: Renders govspeak editor if no visual editor permission is given
  Background:
    Given I am a writer
    And The visual editor private beta feature flag is enabled

  @javascript
  Scenario: I create a new publication
    When I start creating a new publication
    Then I should see the govspeak editor instead of the visual editor

  @javascript
  Scenario: I create a new HTML attachment
    When I start creating a new HTML attachment for publication "Publication with HTML attachments and visual editor"
    Then I should see the govspeak editor instead of the visual editor