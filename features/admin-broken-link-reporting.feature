Feature: Checking a document for broken links

  Documents can be checked for the presence of broken links.

  @without-delay
  Scenario: checking a draft document for broken links
    Given I am a writer
    And a draft document with broken links exists
    When I check the document for broken links
    Then I should a list of the broken links
