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

Scenario: Admin previews of link to a document throughout its lifecycle
  Given I am an editor
  And a draft document "Target" exists
  And a draft document "Source" exists which links to the "Target" document

  Then I should see in the preview that "Source" does not have a public link to "Target"
  And I should see in the preview that "Source" does have an admin link to the draft edition of "Target"

  When I force publish the document "Target"

  Then I should see in the preview that "Source" does have a public link to "Target"
  And I should see in the preview that "Source" does have an admin link to the published edition of "Target"

  When I create a new edition of the published document "Target"

  Then I should see in the preview that "Source" does have a public link to "Target"
  And I should see in the preview that "Source" does have an admin link to the draft edition of "Target"

  When I force publish the document "Target"

  Then I should see in the preview that "Source" does have a public link to "Target"
  And I should see in the preview that "Source" does have an admin link to the published edition of "Target"
