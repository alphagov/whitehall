Feature: Edition update slug

  Rule: The URL control only appears when the title changes

    @javascript
    Scenario: The URL control is revealed when the title changes
      Given I am a writer
      And a published publication "You will never guess" exists
      When I edit the publication "You will never guess"
      Then I cannot see the option to keep the current page URL
      When I change the title to "Ten facts that will shock you"
      Then I can see the option to keep the current page URL

  Rule: Renaming a draft keeps the live URL unless an editor opts out

    Scenario: Renaming a draft keeps the live URL by default
      Given I am a writer
      And a published publication "You will never guess" exists
      When I edit the publication "You will never guess"
      And I change the title to "Ten facts that will shock you"
      And I save the edition and go to the document summary
      Then I can see the preview URL of the publication "Ten facts that will shock you" contains "you-will-never-guess"
      And the saved URL choice for "Ten facts that will shock you" is reflected when revisiting the edit page

    Scenario: Opting to use the title based slug updates the URL to match the title
      Given I am a writer
      And a published publication "You will never guess" exists
      When I edit the publication "You will never guess"
      And I change the title to "Ten facts that will shock you"
      And I opt out of keeping the live slug
      And I save the edition and go to the document summary
      Then I can see the preview URL of the publication "Ten facts that will shock you" contains "ten-facts-that-will-shock-you"
      And the saved URL choice for "Ten facts that will shock you" is reflected when revisiting the edit page
