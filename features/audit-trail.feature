Feature: Audit trail information on a document

  Background:
    Given I am a GDS editor

  @javascript
  Scenario: Audit trail is paginated
    Given a document that has gone through many changes
    When I visit the document to see the audit trail
    Then I can traverse the audit trail with newer and older navigation
