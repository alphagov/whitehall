Feature: Calls For Evidence

  Scenario: Creating a new draft call for evidence
    Given I am a writer
    When I draft a new call for evidence "Beard Length Review"
    Then I should see the call for evidence "Beard Length Review" in the list of draft documents

  Scenario: Submitting a draft call for evidence to a second pair of eyes
    Given I am a writer
    And a draft call for evidence "Beard Length Review" exists
    When I submit the call for evidence "Beard Length Review"
    Then I should see the call for evidence "Beard Length Review" in the list of submitted documents

  @javascript
  Scenario: Associating an offsite call for evidence with topical events
    Given I am an editor
    And a draft call for evidence "Beard Length Review" exists
    When I am on the edit page for call for evidence "Beard Length Review"
    And I mark the call for evidence as offsite
    Then the call for evidence can be associated with topical events
