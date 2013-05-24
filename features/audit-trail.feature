Feature: Audit trail information on a document

  Background:
    Given I am a GDS editor

  Scenario: Audit trail is automatically added to my document
    When I draft and then publish a new document
    Then I should see an audit trail describing my publishing activity on the publication

  @javascript
  Scenario: Audit trail is paginated
    Given a document that has gone through many changes
    When I visit the document to see the audit trail
    Then I can traverse the audit trail with newer and older navigation
