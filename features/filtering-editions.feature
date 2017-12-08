Feature: Filtering Editions

  Background:
    Given there is a topic with published documents that have links
    When I view the documents index page

  Scenario: User filters by broken links
    When I filter by broken links
    Then I see only documents with broken links
