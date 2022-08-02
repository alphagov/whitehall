Feature: Creating and viewing editorial remarks

Background:
  Given I am a writer

Scenario: Adding an editorial remark
  When I add an editorial remark "Try using a spellchecker" to the document "Badddly Rittin"
  Then my editorial remark should be visible with the document

Scenario: Adding an editorial remark with the View move tabs to endpoints permission
  Given I have the "View move tabs to endpoints" permission
  When I visit the edition show page
  Then the "Notes" tab is not visible
  When I visit the edit edition page
  Then the "Notes" tab is not visible
  When I add a french translation
  Then the "Notes" tab is not visible
  When I add an editorial remark "Try using a spellchecker" to the document
  Then my editorial remark should be visible on the notes index page
