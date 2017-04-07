Feature: Checking a document for broken links

  Documents can be checked for the presence of broken links.

  @javascript
  Scenario: checking a draft document for broken links
    Given I am a writer
    And a draft document with broken links exists
    When I check the document for broken links
    Then I should see a list of the broken links

  @javascript
  Scenario: correcting broken links on a document
    Given I am a writer
    And a draft document with broken links exists
    When I check the document for broken links
    Then I should see a list of the broken links
    When I correct the broken links
    Then I should see that the document has no broken links
