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
    Then I should see the visual editor on subsequent edits of the publication
    And I force publish the publication "Publication with visual editor"

  @javascript
  Scenario: I create a new publication and exit the visual editor experience
    When I start creating a new publication
    Then I should see the visual editor instead of the govspeak editor
    When I fill in the required fields for publication "Publication with visual editor" in organisation "Visual ministry"
    And I exit the visual editor experience
    Then I should see the govspeak editor instead of the visual editor
    When I save and go to document summary
    Then I should see the govspeak editor on subsequent edits of the publication

  @javascript
  Scenario: I edit a publication saved with visual editor
    When I edit a publication saved with visual editor
    Then I should see the visual editor instead of the govspeak editor
    When I update the publication in the visual editor
    And I exit the visual editor experience
    And I save and go to document summary
    Then I should see the govspeak editor on subsequent edits of the publication

  @javascript
  Scenario: I edit a publication that has been previously exited
    When I edit a publication that has been previously exited
    Then I should see the govspeak editor
    When I update the publication in the govspeak editor
    And I save and go to document summary
    Then I should see the govspeak editor on subsequent edits of the publication

  @javascript
  Scenario: I edit a pre-existing publication (never edited with visual editor)
    When I edit a pre-existing publication
    Then I should see the govspeak editor
    When I update the publication in the govspeak editor
    And I save and go to document summary
    Then I should see the govspeak editor on subsequent edits of the publication

  @javascript
  Scenario: I create a new HTML attachment
    When I start creating a new HTML attachment for publication "Publication with HTML attachments and visual editor"
    Then I should see the visual editor instead of the govspeak editor
    When I fill in the required fields for HTML attachment "HTML Attachment with visual editor"
    And I save the HTML attachment
    Then I should see the visual editor on subsequent edits of the HTML attachment
    And I force publish the publication "Publication with HTML attachments and visual editor"

  @javascript
  Scenario: I create a new HTML attachment and exit the visual editor experience
    When I start creating a new HTML attachment for publication "Publication with HTML attachments and visual editor"
    Then I should see the visual editor instead of the govspeak editor
    When I fill in the required fields for HTML attachment "HTML Attachment with visual editor"
    And I exit the visual editor experience
    Then I should see the govspeak editor instead of the visual editor
    And I save the HTML attachment
    Then I should see the govspeak editor on subsequent edits of the HTML attachment

  @javascript
  Scenario: I edit an HTML attachment saved with visual editor
    When I edit an HTML attachment saved with visual editor
    Then I should see the visual editor instead of the govspeak editor
    When I update the HTML attachment in the visual editor
    And I exit the visual editor experience
    And I save the HTML attachment
    Then I should see the govspeak editor on subsequent edits of the HTML attachment

  @javascript
  Scenario: I edit an HTML attachment that has been previously exited
    When I edit an HTML attachment that has been previously exited
    Then I should see the govspeak editor
    When I update the HTML attachment in the govspeak editor
    And I save the HTML attachment
    Then I should see the govspeak editor on subsequent edits of the HTML attachment

  @javascript
  Scenario: I edit a pre-existing HTML attachment (never edited with visual editor)
    When I edit a pre-existing HTML attachment
    Then I should see the govspeak editor
    When I update the HTML attachment in the govspeak editor
    And I save the HTML attachment
    Then I should see the govspeak editor on subsequent edits of the HTML attachment