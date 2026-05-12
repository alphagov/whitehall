Feature: Edition update slug

  Scenario: A fresh draft does not show the keep-slug option
    Given I am a writer
    When I begin drafting a new publication "Brand new doc"
    Then I cannot see the option to keep the current page URL
    When I save the edition and go to the document summary
    And I reopen the draft of the publication "Brand new doc"
    And I change the title to "Edited new doc"
    Then I cannot see the option to keep the current page URL

  Scenario: The keep-slug option shows the live URL
    Given I am a writer
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    Then the keep-slug option shows the live URL

  @javascript
  Scenario: The keep-slug option is revealed when the title changes
    Given I am a writer
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    Then I cannot see the option to keep the current page URL
    When I change the title to "Ten facts that will shock you"
    Then I can see the option to keep the current page URL

  Scenario: Writer updates the title of a document and keeps the live slug
    Given I am a writer
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I save my changes to the publication
    Then the option to keep the current page URL is selected
    When I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"
    When I reopen the draft of the publication "Ten facts that will shock you"
    Then the option to keep the current page URL is selected

  Scenario: Writer updates the title of a document and opts in to the slug update
    Given I am a writer
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I opt out of keeping the live slug
    And I save my changes to the publication
    Then the option to update the page URL is selected
    When I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"
    When I reopen the draft of the publication "Ten facts that will shock you"
    Then the option to update the page URL is selected

  Scenario: Editor saves a published document (saved live slug, previously changed title)
    Given I am an editor
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I save the edition and go to the document summary
    And I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"
    And I force publish the publication "Ten facts that will shock you"
    And I edit the publication "Ten facts that will shock you"
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"

  Scenario: Editor updates the title of a published document (saved live slug, previously changed title) and keeps the live slug
    Given I am an editor
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I save the edition and go to the document summary
    And I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"
    And I force publish the publication "Ten facts that will shock you"
    And I edit the publication "Ten facts that will shock you"
    And I change the title to "Remember this person from the 90's"
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Remember this person from the 90's" contains "you-will-never-guess"

  Scenario: Editor updates the title of a published document (saved live slug, previously changed title) and opts out of keeping the live slug
    Given I am an editor
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I save the edition and go to the document summary
    And I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"
    And I force publish the publication "Ten facts that will shock you"
    And I edit the publication "Ten facts that will shock you"
    And I change the title to "Remember this person from the 90's"
    And I opt out of keeping the live slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Remember this person from the 90's" contains "remember-this-person-from-the-90s"

  Scenario: Editor saves a published document (title based slug, previously changed title)
    Given I am an editor
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I opt out of keeping the live slug
    And I save the edition and go to the document summary
    And I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"
    And I force publish the publication "Ten facts that will shock you"
    And I edit the publication "Ten facts that will shock you"
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"

  Scenario: Editor updates the title of a published document (title based slug, previously changed title) and keeps the live slug
    Given I am an editor
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I opt out of keeping the live slug
    And I save the edition and go to the document summary
    And I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"
    And I force publish the publication "Ten facts that will shock you"
    And I edit the publication "Ten facts that will shock you"
    And I change the title to "Remember this person from the 90's"
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Remember this person from the 90's" contains "ten-facts-that-will-shock-you"

  Scenario: Editor updates the title of a published document (title based slug, previously changed title) and opts out of keeping the live slug
    Given I am an editor
    And a published publication "You will never guess" exists
    When I edit the publication "You will never guess"
    And I change the title to "Ten facts that will shock you"
    And I opt out of keeping the live slug
    And I save the edition and go to the document summary
    And I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"
    And I force publish the publication "Ten facts that will shock you"
    And I edit the publication "Ten facts that will shock you"
    And I change the title to "Remember this person from the 90's"
    And I opt out of keeping the live slug
    And I save the edition and go to the document summary
    Then I can see the preview URL of the publication "Remember this person from the 90's" contains "remember-this-person-from-the-90s"