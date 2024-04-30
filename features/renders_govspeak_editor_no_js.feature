Feature: Renders govspeak editor if JS is disabled
  Background:
    Given I am a writer
    And The visual editor private beta feature flag is enabled
    And I have the "Visual editor private beta" permission

  Scenario: I create a new publication
    When I start creating a new publication
    Then I should see the textarea instead of the visual editor

  Scenario: I create a new HTML attachment
    When I start creating a new HTML attachment for publication "Publication with HTML attachments and visual editor"
    Then I should see the textarea instead of the visual editor