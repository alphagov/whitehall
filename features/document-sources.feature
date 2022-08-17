Feature: Managing Document Sources

  I want to manage the legacy urls on a document.

  Background:
    Given I am an importer

  Scenario: Viewing legacy URLs
    Given a draft publication "One must have many urls" with legacy urls "http://im-old.com" and "http://im-really-old.com"
    When I visit the list of draft documents
    And I view the publication "One must have many urls"
    Then I should see the legacy url "http://im-old.com"
     And I should see the legacy url "http://im-really-old.com"

  Scenario: Creating a legacy URL
    Given a draft publication "One must have many urls" exists
    When I add "http://im-old.com" as a legacy url to the "One must have many urls" publication
    And I visit the list of draft documents
    And I view the publication "One must have many urls"
    Then I should see the legacy url "http://im-old.com"

  Scenario: Editing a legacy URL
    Given a draft publication "One must have many urls" with a legacy url "http://im-old.com"
    When I change the legacy url "http://im-old.com" to "http://im-really-old.com" on the "One must have many urls" publication
    And I visit the list of draft documents
    And I view the publication "One must have many urls"
    Then I should see the legacy url "http://im-really-old.com"

  Scenario: Removing a legacy URL
    Given a draft publication "One must have many urls" with a legacy url "http://im-old.com"
    When I remove the legacy url "http://im-old.com" on the "One must have many urls" publication
    And I visit the list of draft documents
    And I view the publication "One must have many urls"
    Then I should see that "http://im-old.com" has been removed
