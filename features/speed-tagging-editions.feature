Feature: Speed tagging editions
  I want to be able to tag new editions (especially but not exclusively imported editions) using a slimmed down version of the edit screen.

  Specifically, the page:
  - should only present policies which are associated with the org of the doc being imported
  - should only present ministers which are associated with the org of the doc being imported
  - should present mandatory data elements for that document type. (i.e. speech type, publication subtype)

  Background:
    Given I am a writer

  Scenario: Speed tagging a newly imported publication
    When I go to speed tag a newly imported publication
    Then I should have to select the publication sub-type

  Scenario: Speed tagging only shows relevant ministers
    Given "Joe Bloggs" is the "Minister" for the "DCLG"
    And "Jane Smith" is the "Minister" for the "Treasury"
    When I go to speed tag a newly imported publication for "DCLG"
    And I should be able to tag the publication with "Joe Bloggs"
    And I should not be able to tag the publication with "Jane Smith"

  Scenario: Speed tagging only shows relevant policies
    Given a published policy "Local beards" for the organisation "DCLG"
    And a published policy "Beard taxes" for the organisation "Treasury"
    When I go to speed tag a newly imported publication for "DCLG"
    And I should be able to tag the publication with "Local beards"
    And I should not be able to tag the publication with "Beard taxes"

  Scenario: Speed tagging shows speech required fields
    When I go to speed tag a newly imported speech
    Then I should have to select the speech type
    And I should have to select the deliverer of the speech
