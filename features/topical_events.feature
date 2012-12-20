Feature: As an editor
I want to be able to create and publish topical events
So that I can communicate about them

Background:
  Given I am an editor

Scenario: Adding a new topical event
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing"
  Then I should see the topical event "Moustache Growing Convention" in the admin interface
  And I should see the topical event "Moustache Growing Convention" on the frontend

@wip
Scenario: Associating a speech with a topical event
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing"
  And I draft a new speech "Famous moustaches of the 19th century" relating it to topical event "Moustache Growing Convention"
  And I force publish the speech "Famous moustaches of the 19th century"
  Then I should see the speech "Famous moustaches of the 19th century" in the announcements section of the topical event "Moustache Growing Convention"
