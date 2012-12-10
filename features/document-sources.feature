Feature: Managing Document Sources

I want to manage the legacy urls on a document.

  Background:
    Given I am a writer

  Scenario: Viewing the legacy URL
    Given a draft publication "One must have many urls" with a legacy url "http://im-old.com"
    When I visit the list of draft documents
    And I view the publication "One must have many urls"
    Then I should see the legacy url "http://im-old.com"