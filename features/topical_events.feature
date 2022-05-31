Feature: Creating and publishing topical events
  As an editor
  I want to be able to create and publish topical events
  So that I can communicate about them

Background:
  Given I am an editor
  Given search returns no results

Scenario: Adding a new topical event
  When I create a new topical event "An Event" with summary "A topical event" and description "About this topical event"
  Then I should see the topical event "An Event" in the admin interface
  And I should see the topical event "An Event" on the frontend

Scenario: Archiving a new topical event
  When I create a new topical event "An Event" with summary "A topical event", description "About this topical event" and it ends today
  Then I should see the topical event "An Event" in the admin interface
  And I should see the topical event "An Event" on the frontend is archived

Scenario: Associating a speech with a topical event
  Given a topical event called "An Event" with summary "A topical event" and description "About this topical event"
  When I draft a new speech "A speech" relating it to topical event "An Event"
  And I force publish the speech "A speech"
  Then I should see the speech "A speech" in the announcements section of the topical event "An Event"

Scenario: Associating a publication with a topical event
  Given a topical event called "An Event" with summary "A topical event" and description "About this topical event"
  When I draft a new publication "A speech" relating it to topical event "An Event"
  And I force publish the publication "A speech"
  Then I should see the publication "A speech" in the publications section of the topical event "An Event"

Scenario: Associating a consultation with a topical event
  Given a topical event called "An Event" with summary "A topical event" and description "About this topical event"
  When I draft a new consultation "A Consultation" relating it to topical event "An Event"
  And I check "A Consultation" adheres to the consultation principles
  And I force publish the consultation "A Consultation"
  Then I should see the consultation "A Consultation" in the consultations section of the topical event "An Event"

Scenario: Creating offsite content on a topical event page
  Given a topical event called "An Event" with summary "A topical event" and description "About this topical event"
  When I add the offsite link "Offsite Thing" of type "Alert" to the topical event "An Event"
  Then I should see the edit offsite link "Offsite Thing" on the "An Event" topical event page

Scenario: Featuring offsite content on a topical event page
  Given a topical event called "An Event" with summary "A topical event" and description "About this topical event"
  And I have an offsite link "Offsite Thing" for the topical event "An Event"
  When I feature the offsite link "Offsite Thing" for topical event "An Event" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured offsite links in the "An Event" topical event are:
    | Offsite Thing | s465_minister-of-funk.960x640.jpg |

Scenario: Featuring a document collection on an topical event page
  Given a topical event called "An Event" with summary "A topical event" and description "About this topical event"
  When I draft a new document collection "A document collection" relating it to topical event "An Event"
  And I force publish the document collection "A document collection"
  When I feature the document "A document collection" for topical event "An Event" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured documents in the "An Event" topical event are:
    | A document collection | s465_minister-of-funk.960x640.jpg |

Scenario: Adding more information about the event
  Given I'm administering a topical event
  And I add a page of information about the event
  Then I should be able to edit the event's about page
  And a link to the event's about page is visible

Scenario: Deleting a topical event
  Given a topical event called "An event" with summary "A topical event" and description "A topical event"
  Then I should be able to delete the topical event "An event"
