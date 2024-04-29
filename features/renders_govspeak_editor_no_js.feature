Feature: Renders govspeak editor if JS is disabled
  Background:
    Given I am a writer
    And The visual editor private beta feature flag is enabled
    And I have the "Visual editor private beta" permission

  Scenario: I create a new publication
    When I start creating a new publication
    Then I should see the textarea instead of the visual editor
