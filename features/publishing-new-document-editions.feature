Feature: Creating document editions
As a writer,
I want publish a new edition of a document without all of the links to it disappearing
So that the website hangs together as an interconnected set of pages.

Scenario: Publishing a new edition of a document linked to by another document
  Given I am an editor
  And a published document "Ban beards" exists
  And a published document "Ban moustaches" exists which links to the "Ban beards" document

  When I publish a new edition of the published document "Ban beards"

  Then the published document "Ban moustaches" should still link to the "Ban beards" document
