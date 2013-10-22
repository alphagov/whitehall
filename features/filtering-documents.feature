@not-quite-as-fake-search
Feature: Filtering Documents

  As a citizen, I want to be able to browse various types of content by filtering down by the following attributes.

  - Publications (inc. Consultations & Statistics):
    - Keyword
    - Publication type
    - Topic
    - Department
    - World locations
    - Published date

  - Policies
    - Keyword
    - Topic
    - Department

  - Announcements
    - Keyword
    - Announcement type
    - Topic
    - Department
    - World Location
    - Published date

  - Viewing translated index page
    - e.g. https://www.gov.uk/government/announcements.fr?include_world_location_news=1&world_locations[]=france

    - c.f. world-location-news.feature


  Scenario: User filters policies, combining filters
    Given I'm looking at the policies index showing several policies with various attributes
    When I filter by a topic
    Then I should only see policies for that topic
    When I also filter by a department
    Then I should only see policies for both the topic and the department
    When I also filter by a keyword
    Then I should only see policies for the topic, the department and the keyword

  Scenario: User filters publications using each filter one at a time
    Given I'm looking at the publications index showing several publications with various attributes
    When I filter by only a publication type
    Then I should only see the publications of that publication type
    When I filter by only a topic
    Then I should only see publications for that topic
    When I filter by only a department
    Then I should only see publications for that department
    When I filter by only a world location
    Then I should only see publications for that world location
    When I filter by only published date
    Then I should only see publications for the published date range

  Scenario: User filters announcements combining all filters
    Given I'm looking at the announcements index showing several announcements with various attributes
    When I filter by a keyword, an announcement type, a topic, a department, a world location and published date
    Then I should only see announcements matching those filters

  @javascript
  Scenario: User filters publications with javascript enabled
    Given I'm looking at the publications index showing several publications with various attributes
    When I filter by a keyword
    Then I should only see publications for that keyword
    When I also filter by a department
    Then I should only see publications for the keyword and department

  Scenario: User visits the announcements index in french
    Given I'm looking at the announcements index in french
    Then I can only filter by world location (or Pays in french)

  Scenario: User filters by "Statistics" which returns statistics and national statistics
    Given a published publication "Road accidents" with type "Statistics"
    And a published publication "National road accidents" with type "Statistics - national statistics"
    When I filter the publications list by "Statistics"
    Then I should see "Road accidents" in the result list
    And I should see "National road accidents" in the result list
