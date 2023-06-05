Feature: Statistical release announcements

  As an publisher of government statistics
  I want to be able to announce upcoming statistics publications
  So that citizens can see which statistics publications are coming soon and when they will be published.

  Scenario: announcing an upcoming statistics publication
    Given I am a GDS editor in the organisation "Department for Beards"
    When I announce an upcoming statistics publication called "Monthly Beard Stats"
    Then I should see the announcement listed on the list of announcements

  Scenario: drafting a document from a statistics announcement
    Given I am a GDS editor in the organisation "Department for Beards"
    And a statistics announcement called "Monthly Beard Stats" exists
    When I draft a document from the announcement
    Then the document fields are pre-filled based on the announcement
    When I save the draft statistics document
    Then the document becomes linked to the announcement

  Scenario: changing the date on a statistics announcement
    Given I am a GDS editor in the organisation "Department for Beards"
    And a statistics announcement called "Monthly Beard Stats" exists
    When I change the release date on the announcement
    Then the new date is reflected on the announcement

  Scenario: searching for a statistics announcement
    Given I am a GDS editor in the organisation "Department for Beards"
    And a statistics announcement called "MQ5 statistics" exists
    And a statistics announcement called "PQ3 statistics" exists
    When I search for announcements containing "MQ5"
    And I should only see a statistics announcement called "MQ5 statistics"

  Scenario: filtering statistics announcements by organisation
    Given I am a GDS editor in the organisation "Department for Beards"
    And there is a statistics announcement by my organisation
    And there is a statistics announcement by another organistion
    Then I should see my organisation's statistics announcements on the statistical announcements page by default
    When I filter statistics announcements by the other organisation
    Then I should only see the statistics announcement of the other organisation

  Scenario: filtering announcements according to date
    Given I am a GDS editor in the organisation "Department for Beards"
    And there are statistics announcements by my organisation
    Then I should be able to filter both past and future announcements

  Scenario: filtering announcements that are not linked to a publications
    Given I am a GDS editor in the organisation "Department for Beards"
    And there are statistics announcements by my organisation
    Then I should be able to filter only the unlinked announcements

  Scenario: viewing unlinked statistics announcements that are imminent
    Given I am a GDS editor in the organisation "Department for Beards"
    And there are statistics announcements by my organisation that are unlinked to a publication
    When I view the statistics announcements index page
    Then I should see a warning that there are upcoming releases without a linked publication
    And I should be able to view these upcoming releases without a linked publication

  @javascript
  Scenario: linking a document to a statistics announcement
    Given I am a GDS editor in the organisation "Department for Beards"
    And a draft statistics publication called "Beard statistics - January 2014"
    And a statistics announcement called "January's beard statistics" exists
    When I link the announcement to the publication
    Then I should see that the announcement is linked to the publication

  Scenario: cancelling a statistics announcement
    Given I am a GDS editor in the organisation "Department for Beards"
    And a statistics announcement called "Beard grooming spending 2014" exists
    When I cancel the statistics announcement
    Then I should see that the statistics announcement has been cancelled
    And I should see "Announcement cancelled" in the history

  Scenario: editing a cancellation reason
    Given I am a GDS editor in the organisation "Department for Beards"
    And a cancelled statistics announcement exists
    When I change the cancellation reason
    Then I should see the updated cancellation reason

  Scenario: unpublishing a statistics announcement
    Given I am a GDS editor in the organisation "Department for Beards"
    And a statistics announcement called "Beard grooming spending 2014" exists
    When I unpublish the statistics announcement
    Then I should see the unpublish statistics announcement banner
    And I should see no statistic announcements
