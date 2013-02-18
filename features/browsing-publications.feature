Feature: Browsing publications

  As a citizen, I want to be able to view and browse publications using a filter so that I can easily find publications that I'm interested in.

  - The citizens should be able to employ these different filters:
    - Topics
    - Departments
    - Publication types
    - Keywords
    - Date (published before/after)

  - "Statistics" and "National statistics" publication types should be merged together into a "Statistics" type for filtering purposes

  @not-quite-as-fake-search
  Scenario: User filters by "Statistics" which returns statistics and national statistics
    Given a published publication "Road accidents" with type "Statistics"
    And a published publication "National road accidents" with type "Statistics - national statistics"
    When I filter the publications list by "Statistics"
    Then I should see "Road accidents" in the result list
    And I should see "National road accidents" in the result list
