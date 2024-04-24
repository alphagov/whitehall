Feature: Renders govspeak editor if no visual editor permission is given
  Background:
    Given I am a writer
    And The visual editor private beta feature flag is enabled

  @javascript
  Scenario: I create a new publication
    When I start creating a new publication
    Then I should see the govspeak editor instead of the visual editor
