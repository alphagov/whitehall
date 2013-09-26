Feature: Creating and publishing topical events
  As an editor
  I want to be able to create and publish topical events
  So that I can communicate about them

Background:
  Given I am an editor

Scenario: Adding a new topical event
  When I create a new topical event "An Event" with description "A topical event"
  Then I should see the topical event "An Event" in the admin interface
  And I should see the topical event "An Event" on the frontend

Scenario: Archiving a new topical event
  When I create a new topical event "An Event" with description "A topical event" and it ends today
  Then I should see the topical event "An Event" in the admin interface
  And I should not see the topical event "An Event" on the topics listing
  And I should see the topical event "An Event" on the frontend is archived

Scenario: Associating a speech with a topical event
  Given a topical event called "An Event" with description "A topical event"
  When I draft a new speech "A speech" relating it to topical event "An Event"
  And I force publish the speech "A speech"
  Then I should see the speech "A speech" in the announcements section of the topical event "An Event"
  And the speech "A speech" shows it is related to the topical event "An Event" on its public page

Scenario: Associating a news article with a topical event
  Given a topical event called "An Event" with description "A topical event"
  When I draft a new news article "A speech" relating it to topical event "An Event"
  And I force publish the news article "A speech"
  Then I should see the news article "A speech" in the announcements section of the topical event "An Event"
  And the news article "A speech" shows it is related to the topical event "An Event" on its public page

Scenario: Associating a publication with a topical event
  Given a topical event called "An Event" with description "A topical event"
  When I draft a new publication "A speech" relating it to topical event "An Event"
  And I force publish the publication "A speech"
  Then I should see the publication "A speech" in the publications section of the topical event "An Event"
  And the publication "A speech" shows it is related to the topical event "An Event" on its public page

Scenario: Associating a consultation with a topical event
  Given a topical event called "An Event" with description "A topical event"
  When I draft a new consultation "A Consultation" relating it to topical event "An Event"
  And I force publish the consultation "A Consultation"
  Then I should see the consultation "A Consultation" in the consultations section of the topical event "An Event"
  And the consultation "A Consultation" shows it is related to the topical event "An Event" on its public page

Scenario: Featuring news on an topical event page
  Given a topical event called "An Event" with description "A topical event"
  When I draft a new news article "A speech" relating it to topical event "An Event"
  And I force publish the news article "A speech"
  When I feature the news article "A speech" for topical event "An Event" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured news articles in the "An Event" topical event are:
    | A speech | s465_minister-of-funk.960x640.jpg |

Scenario: Adding more information about the event
  Given I'm administering a topical event
  And I add a page of information about the event
  Then I should be able to edit the event's about page
  And the information about the event should be visible on its public page
