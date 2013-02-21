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
    Given I am an editor

  Scenario: Create a world location news article
    When I create a world location news article "Beirut News"
    Then the world location news article "Beirut News" should have been created

  Scenario: Associate a world location news article with an worldwide priority
    Given a published worldwide priority "Helping local people" exists
    When I create a valid world location news article "Beirut News"
    Then I should be able to associate "Beirut News" with the worldwide priority "Helping local people"
    And see the world location news article "Beirut News" appear on the worldwide priority "Helping local people"

  Scenario: Cannot associate normal articles with a worldwide priority
    When I draft a new news article "Normal news"
    Then I cannot associate "Normal News" with worldwide priorities

  Scenario: Associate a world location news article with a worldwide organisation
    Given the worldwide organisation "Spanish Department" exists
    When I create a valid world location news article "Spanish News"
    Then I should be able to associate "Spanish News" with the worldwide organisation "Spanish Department"
    And see the worldwide organisation "Spanish Department" listed as a producing org on the world location news article "Spanish News"

  Scenario: Associate a world location news article with a worldwide location
    Given a country "Indonesia" exists
    When I create a valid world location news article "Indonesian Beer"
    Then I should be able to associate "Indonesian Beer" with the worldwide location "Indonesia"
    When I visit the worldwide location "Indonesia"
    Then I should see the world location news article "Indonesian Beer"

  Scenario: World location news shouldn't appear on announcements index
    Given I create a valid world location news article "French things"
    When I browse to the announcements index
    Then I should not be able to see a world location news article "French things"
