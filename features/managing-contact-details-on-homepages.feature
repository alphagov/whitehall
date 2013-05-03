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

  Scenario: Arranging contacts for an organisation
    Given there is an organisation with some contacts on its home page
    When I add a new contact to be featured on the home page of the organisation
    And I reorder the contacts to highlight my new contact
    Then I see the contacts in my specified order including the new one on the home page of the organisation

  Scenario: FOI contacts for an organisation
    Given there is an organisation with some contacts on its home page
    When I add a new FOI contact to the organisation without adding it to the list of contacts for the home page
    Then I see the new FOI contact listed on the home page only once, in the FOI section

  Scenario: Removing contacts from the home page of an organisation
    Given there is an organisation with some contacts on its home page
    When I decide that one of the contacts no longer belongs on the home page
    Then that contact is no longer visible on the home page of the organisation

  Scenario: Arranging offices for a worldwide organisation
    Given there is a worldwide organisation with some offices on its home page
    When I add a new office to be featured on the home page of the worldwide organisation
    And I reorder the offices to highlight my new office
    Then I see the offices in my specified order including the new one under the main office on the home page of the worldwide organisation

  Scenario: Removing offices from the home page of a worldwide organisation
    Given there is a worldwide organisation with some offices on its home page
    When I decide that one of the offices no longer belongs on the home page
    Then that office is no longer visible on the home page of the worldwide organisation

