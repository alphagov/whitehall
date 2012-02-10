Feature: Removing documents published in error
s an editor, 
I want a way to unpublish documents that were published in error, 
So that incorrect content does not appear to the public

Scenario: Deleting a document that has one edition
  Given I am an editor
  And a published document "Ban beards" exists
  When I delete the document "Ban beards"
  Then there should not be a document called "Ban beards"
