Feature: Creating and viewing editorial remarks

Scenario: Adding an editorial remark
  Given I am a writer
  When I add an editorial remark "Try using a spellchecker" to the document "Badddly Rittin"
  Then my editorial remark should be visible with the document