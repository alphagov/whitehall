Feature: World location news for people local to countries
  As a citizen,
  I want news articles which are only relevant in a specific world location to be excluded from the main list of announcements on inside government unless I choose to see them,
  So that I can ignore this niche interest content unless I want it

  ---

  A way of creating a 'world location specific' news article

  Include these on the location page's list of recent announcements,
  latest feed etc, and allow them to be featured on a world location
  page

  Omit these from the /announcements list unless a frontend user
  selects to reveal them (needs UX input, but something like a
  checkbox below the worldwide filter: 'Include location-specific
  news' defaulting to unchecked).

  Users can still see any standard news articles that are tagged to
  countries (eg FCO news about Syria) - only the location-specific
  stuff should be filtered out

  'See all our announcements' link from the location goes to filtered
  announcements list including the location specific stuff

  World location-specific news articles should be associated to
  Worldwide organisations, as well as to locations, so the world
  organisation logos are shown as the producing orgs

  It should be possible to associate them to worldwide priorities
  (not to policies). Doing so should make them appear on a latest tab
  on the worldwide priority.

  Background:
    Given I am an GDS editor

  Scenario: Create a world location news article
    When I draft a valid world location news article "Beirut News"
    Then the world location news article "Beirut News" should have been created

  Scenario: Associate a world location news article with a worldwide organisation
    Given the worldwide organisation "Spanish Department" exists
    When I draft a valid world location news article "Spanish News"
    Then I should be able to associate "Spanish News" with the worldwide organisation "Spanish Department"
    When I force publish the world location news article "Spanish News"
    Then the worldwide organisation "Spanish Department" is listed as a producing org on the world location news article "Spanish News"

  @not-quite-as-fake-search
  Scenario: Associate a world location news article with a world location
    Given a world location "Indonesia" exists
    When I draft a valid world location news article "Indonesian Beer"
    Then I should be able to associate "Indonesian Beer" with the world location "Indonesia"
    When I force publish the world location news article "Indonesian Beer"
    Then the world location news article "Indonesian Beer" appears on the world location "Indonesia"
    When I click through to see all the announcements for world location "Indonesia"
    Then I should see the world location news article "Indonesian Beer"

  @not-quite-as-fake-search
  Scenario: World location news on the announcements index
    Given there is a world location news article
    When I browse to the announcements index
    Then I should not be able to see the world location news article
    When I explicitly ask for world location news to be included
    Then I should be able to see the world location news article
