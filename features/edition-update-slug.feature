Feature: Edition update slug

  Scenario: Writer updates the title of a document and keeps the live slug
    Given I am a writer
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"

  Scenario: Writer updates the title of a document and opts in to the slug update
    Given I am a writer
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I opt out of keeping the live slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"
