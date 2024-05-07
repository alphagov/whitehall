Feature: Renders govspeak editor if no visual editor permission is given
  Background:
    Given I am a writer
    And The visual editor private beta feature flag is enabled

  @javascript
  Scenario: I create a new publication
    When I start creating a new publication
    Then I should see the govspeak editor

  @javascript
  Scenario: I edit a publication saved with visual editor
    When I edit a publication saved with visual editor
    Then I should see the govspeak editor
    When I update the publication in the govspeak editor
    And I save and go to document summary
    Then I should see the govspeak editor on subsequent edits of the publication

  @javascript
  Scenario: I create a new HTML attachment
    When I start creating a new HTML attachment for publication "Publication with HTML attachments and visual editor"
    Then I should see the govspeak editor

  @javascript
  Scenario: I edit an HTML attachment saved with visual editor
    When I edit an HTML attachment saved with visual editor
    Then I should see the govspeak editor
    When I update the HTML attachment in the govspeak editor
    And I save the HTML attachment
    Then I should see the govspeak editor on subsequent edits of the HTML attachment