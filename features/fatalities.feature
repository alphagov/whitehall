Feature: Fatalities

  As a citizen,
  I want to see a rolling list of fatalities incurred by armed forces per field of operation,
  So that this information is fully transparent and comprehensive

  This is a sensitive issue, and MOD have refined a way of publishing it which they are keen to replicate.

  See the following Examples:

    http://www.mod.uk/DefenceInternet/FactSheets/OperationsFactsheets/OperationsInIraqBritishFatalities.htm
    http://www.mod.uk/DefenceInternet/FactSheets/OperationsFactsheets/OperationsInAfghanistanBritishFatalities.htm

  Detail (confirmed by MOD):

  - MOD need to be able to feature fatality notices prominently on the MOD homepage
  - There will usually not be a high quality image to use on the homepage or the item itself, but the MOD are going to handle this by photoshopping the images themselves.
  - There needs to be a list of all fatalities, and lists grouped per field of operation. Eg all Afghanistan fatalities on one page, with an introduction specific to that field of operation - ie there needs to be an admin interface to create a field of operation and input introduction text in markdown.
  - A Field of Operation may not correspond directly to a country, for example 'horn of africa' - we need a new concept in the system
  - The fatality notice itself is a short paragraph of text, listed in reverse chronology on the all fatalities list and the relevant field of operations.
  - 24 hours after, the fatality notice links through to a eulogy per person listed. The eulogy is a lot like a news article (MOD uses their news format), but will need to be a seperate type.
  - Only MOD writers/editors should be able to create these.
  - The 24 hour 'delay' is done manually: no pre-scheduling or automation needed.

  Implementation notes:

  - We'll model fatality notices as a new edition type. Fatality Notices will be editioned to add the eulogies later.
  - We'll create a new FieldOfOperation model in the schema, which can only be associated with Fatality Notices.
  - Fatalities should show on the announcements index, with a filter
  - Link ministers too
  - Introduction text for the fatality notice to be displayed on the Field of Operation page is separate to the Summary

  Background:
    Given an organisation "MOD" has been assigned to handle fatalities
    And I am an editor in the organisation "MOD"

  Scenario: Editor adds field of operation
    When I create a new field of operation called "New Field" with description "Description"
    Then I am able to associate fatality notices with "New Field"

  @not-quite-as-fake-search
  Scenario: Writer creates a fatality notice
    When I create a fatality notice titled "Death of Joe" in the field "Iraq"
    Then the fatality notice should be visible on the public site
    And the document should be clearly marked as a fatality notice
    And the document should show the field of operation as "Iraq"

  Scenario: Writer links minister with a fatality notice
    Given there is a fatality notice titled "Death of Joe" in the field "Iraq"
    When I link the minister "Nick Smith" to the fatality notice
    Then I should see the minister's name listed at the top

  Scenario: Citizen looks at field of operations information
    Given there is a fatality notice titled "Death of Joe and Jim" in the field "Iraq"
    When I look at the fatality notice titled "Death of Joe and Jim"
    Then I can view the field of operations information from a link in the metadata
    And I can see the roll call introduction of the fatality notice titled "Death of Joe and Jim"

  @not-quite-as-fake-search
  Scenario: Citizen sees all fatalities in a filtered list
    Given there is a fatality notice titled "Death of Joe and Jim" in the field "Iraq"
    When I visit the list of announcements
    Then I can view the field of operations information from a link in the metadata

  Scenario: Only editors/writers from organisations which handle fatalities can create fatality notices
    Given I am a writer in the organisation "DFT"
    Then I cannot edit fields of operation
    And I cannot create new fatality notices

  Scenario: GDS editors can also edit fatality notices
    Given I am a GDS editor
    Then I can create a fatality notice
