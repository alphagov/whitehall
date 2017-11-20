Feature: World location news
  As a citizen,
  I want news articles which are only relevant in a specific world location to be excluded from the main list of announcements on inside government unless I choose to see them,
  So that I can ignore this niche interest content unless I want it

  ---

  World Location News Articles are being replaced by News Articles of type
  'World news story' and it is not possible to create these anymore. They can
  still be viewed though.

  Include these on the location page's list of recent announcements,
  latest feed etc, and allow them to be featured on a world location
  page.

  Omit these from the /announcements list unless a frontend user
  selects to reveal them (needs UX input, but something like a
  checkbox below the worldwide filter: 'Include location-specific
  news' defaulting to unchecked).

  Users can still see any standard news articles that are tagged to
  countries (eg FCO news about Syria) - only the location-specific
  stuff should be filtered out.

  'See all our announcements' link from the location goes to filtered
  announcements list including the location specific stuff.

  World location-specific news articles should be associated to
  Worldwide organisations, as well as to locations, so the world
  organisation logos are shown as the producing orgs.

  Background:
    Given I am an GDS editor

  @not-quite-as-fake-search
  Scenario: World location news on the announcements index
    Given there is a world location news article
    When I browse to the announcements index
    Then I should not be able to see the world location news article
    When I explicitly ask for world location news to be included
    Then I should be able to see the world location news article

  Scenario: View news articles relating to an international delegation
    Given an international delegation "UK and the World Government" exists
    And a published news article "World Government publishes fishing statistics for the Atlantic Ocean" exists relating to the international delegation "UK and the World Government"
    When I view the international delegation "UK and the World Government"
    Then I should see the news article "World Government publishes fishing statistics for the Atlantic Ocean"

  Scenario: The publication is about an international delegation
    Given an international delegation "UK and the World Government" exists
    And a published publication "Penguins have rights too" exists that is about "UK and the World Government"
    When I view the international delegation "UK and the World Government"
    Then I should see the publication "Penguins have rights too"

  Scenario: Inactive world locations are listed but not linked
    Given the world location "Democratic People's Republic of South London" is inactive
    When I visit the world locations page
    Then I should see a world location called "Democratic People's Republic of South London"
    But I should not see a link to the world location called "Democratic People's Republic of South London"
