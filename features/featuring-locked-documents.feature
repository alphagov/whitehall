Feature: Featuring locked documents

Background:
  Given a document titled "Quidditch World Cups comes to Hogsmeade"

Scenario: Featuring a locked document on an organisation page
  Given the organisation "Department of Magical Games and Sports" exists
  And the document is tagged to organisation "Department of Magical Games and Sports"
  And the document is locked
  When I visit the organisation admin page for "Department of Magical Games and Sports"
  And I search for a document titled "Quidditch World Cups comes to Hogsmeade" in the list of featurable documents
  Then I cannot see the document in the list of featurable documents

Scenario: Featuring a locked document on a world location page
  Given a world location "Hogsmeade" exists
  And the document is tagged to the world location "Hogsmeade"
  And the document is locked
  When I visit the world location admin page for "Hogsmeade"
  And I search for a document titled "Quidditch World Cups comes to Hogsmeade" in the list of featurable documents
  Then I cannot see the document in the list of featurable documents

Scenario: Featuring a locked document on a topical event page
  Given a topical event called "Quidditch World Cup" with summary "World cup" and description "Sporting event"
  And the document is tagged to the topical event "Quidditch World Cup"
  And the document is locked
  And I visit the topical event admin page for "Quidditch World Cup"
  And I search for a document titled "Locked document" in the list of featurable documents
  Then I cannot see the document in the list of featurable documents
