Feature: managing contact details on home pages
  Editors need to be able to manage contact details on homepages, so that
  they can show important contact details first, and skip showing
  unimportant details.

  Contact details comprise contact records on organisation pages, and
  offices on world organisation pages.

  Contacts can also be marked with their type, and on organisation pages
  FOI contacts are displayed separately from the rest of the list

  Background:
    Given I am a GDS editor
    And a world location "United Kingdom" exists

  Scenario: Arranging offices for a worldwide organisation
    Given there is a worldwide organisation with some offices on its home page
    When I add a new office to be featured on the home page of the worldwide organisation
    And I reorder the offices to highlight my new office
    Then I see the offices in my specified order including the new one under the main office on the home page of the worldwide organisation

  Scenario: Removing offices from the home page of a worldwide organisation
    Given there is a worldwide organisation with some offices on its home page
    When I decide that one of the offices no longer belongs on the home page
    Then that office is no longer visible on the home page of the worldwide organisation

