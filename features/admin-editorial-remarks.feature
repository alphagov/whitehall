Feature: Creating and viewing editorial remarks

  Background:
    Given I am a writer

  @design-system-wip
  Scenario: Adding an editorial remark
    When I add an editorial remark "Try using a spellchecker" to the document "Badddly Rittin"
    Then my editorial remark should be visible with the document
