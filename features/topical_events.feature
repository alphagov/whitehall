Feature: Creating and publishing topical events
  As an editor
  I want to be able to create and publish topical events
  So that I can communicate about them

Background:
  Given I am an editor

Scenario: Adding a new topical event
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing"
  Then I should see the topical event "Moustache Growing Convention" in the admin interface
  And I should see the topical event "Moustache Growing Convention" on the frontend

Scenario: Archiving a new topical event
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing" and it ends today
  Then I should see the topical event "Moustache Growing Convention" in the admin interface
  And I should not see the topical event "Moustache Growing Convention" on the topics listing
  And I should see the topical event "Moustache Growing Convention" on the frontend is archived

Scenario: Associating a speech with a topical event
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing"
  And I draft a new speech "Famous moustaches of the 19th century" relating it to topical event "Moustache Growing Convention"
  And I force publish the speech "Famous moustaches of the 19th century"
  Then I should see the speech "Famous moustaches of the 19th century" in the announcements section of the topical event "Moustache Growing Convention"

Scenario: Associating a news article with a topical event
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing"
  And I draft a new news article "Famous moustaches of the 19th century" relating it to topical event "Moustache Growing Convention"
  And I force publish the news article "Famous moustaches of the 19th century"
  Then I should see the news article "Famous moustaches of the 19th century" in the announcements section of the topical event "Moustache Growing Convention"

Scenario: Featuring news on an topical event page
  When I create a new topical event "Moustache Growing Convention" with description "Annual convention on moustach growing"
  And I draft a new news article "Famous moustaches of the 19th century" relating it to topical event "Moustache Growing Convention"
  And I force publish the news article "Famous moustaches of the 19th century"
  When I feature the news article "Famous moustaches of the 19th century" for topical event "Moustache Growing Convention" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured news articles in the "Moustache Growing Convention" topical event are:
    | Famous moustaches of the 19th century | s465_minister-of-funk.960x640.jpg |
