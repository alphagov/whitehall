Feature: Edition update slug
#  @javascript
#  The live editions slug_override is nil / no inherited override
  Scenario: Writer keeps live slug when updating the title of a document
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I choose to keep the live slug
    When I click save
    Then I see an unchecked checkbox for opting in to the title based slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "New title" contains "previously-published"

#  @javascript
#  The live editions slug_override is nil / no inherited override
  Scenario: Writer chooses to use title-based slug when updating the title of a document
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I opt in to use the title based slug
    When I click save
    Then I see a checked checkbox for opting in to the title based slug
    When I save the edition and go to the document summary
    Then I can see the preview URL of the publication "New title" contains "new-title"

#  @javascript
#  The live editions slug_override is nil or blank, but from previous user choice.
  Scenario: Writer redrafts and saves a published edition with title based slug
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I opt in to use the title based slug
    And I save the edition and go to the document summary
    Then I force publish the publication "New title"
    When I edit the publication "New title"
    Then I see an unchecked checkbox for opting in to the title based slug
    When I click save
    Then I see an unchecked checkbox for opting in to the title based slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "New title" contains "new-title"

#  @javascript
# The live editions slug_override is nil or blank, but from previous user choice.
  Scenario: Writer redrafts and publishes a published edition with title based slug - and changes title, opting to use title based slug
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I opt in to use the title based slug
    And I save the edition and go to the document summary
    Then I force publish the publication "New title"
    When I edit the publication "New title"
    Then I see an unchecked checkbox for opting in to the title based slug
#   Then I see no checkbox to opt in to the title based slug - if js
    And I change the title to "Changed title"
    And I opt in to use the title based slug
    When I click save
    Then I see a checked checkbox for opting in to the title based slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Changed title" contains "changed-title"

#  @javascript
#    The live editions slug_override is nil or blank, but from previous user choice.
  Scenario: Writer redrafts and views a published edition with title based slug - and changes title, opting to use live slug
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I opt in to use the title based slug
    And I save the edition and go to the document summary
    Then I force publish the publication "New title"
    When I edit the publication "New title"
    Then I see an unchecked checkbox for opting in to the title based slug
#    Then I see no checkbox to opt in to the title based slug - if js
    And I change the title to "Changed title"
    And I choose to keep the live slug
    When I click save
    Then I see an unchecked checkbox for opting in to the title based slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Changed title" contains "new-title"    

#  @javascript
#    The live editions slug_override is set to a custom slug, not title based
  Scenario: Writer redrafts and saves a published edition with custom slug
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I choose to keep the live slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "New title" contains "previously-published"
    Then I force publish the publication "New title"
    When I edit the publication "New title"
    #    Then I see no checkbox to opt in to the title based slug - if js
    Then I see an unchecked checkbox for opting in to the title based slug
    When I click save
    Then I see an unchecked checkbox for opting in to the title based slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "New title" contains "previously-published"
    
#  @javascript
#    The live editions slug_override is set to a custom slug, not title based
  Scenario: Writer redrafts and saves a published edition with custom slug - and changes title, opting to keep live slug
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I choose to keep the live slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "New title" contains "previously-published"
    Then I force publish the publication "New title"
    When I edit the publication "New title"
    # Then I see no checkbox to opt in to the title based slug - if js
    Then I see an unchecked checkbox for opting in to the title based slug
    Then I change the title to "Changed title"
    And I choose to keep the live slug
    When I click save
    Then I see an unchecked checkbox for opting in to the title based slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Changed title" contains "previously-published"

#  @javascript
#    The live editions slug_override is set to a custom slug, not title based
  Scenario: Writer redrafts and saves a published edition with custom slug - and changes title, opting to keep title based slug
    Given I am a writer
    And a published publication "Previously published" exists
    When I edit the publication "Previously published"
    And I change the title to "New title"
    And I choose to keep the live slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "New title" contains "previously-published"
    Then I force publish the publication "New title"
    When I edit the publication "New title"
    # Then I see no checkbox to opt in to the title based slug - if js
    Then I see an unchecked checkbox for opting in to the title based slug
    Then I change the title to "Changed title"
    And I opt in to use the title based slug
    When I click save
    Then I see a checked checkbox for opting in to the title based slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Changed title" contains "changed-title"