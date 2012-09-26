Feature: Editing draft detailed guide

Background:
  Given I am a writer

Scenario: Creating a new draft detailed guide
  When I draft a new detailed guide "The finer points of moustache trimming"
  Then I should see the detailed guide "The finer points of moustache trimming" in the list of draft documents

Scenario: Creating a new draft detailed guide in multiple topics
  Given two topics "Facial Hair" and "Hirsuteness" exist
  When I draft a new detailed guide "Outlaw Moustaches" in the "Facial Hair" and "Hirsuteness" topics
  Then I should see in the preview that "Outlaw Moustaches" should be in the "Facial Hair" and "Hirsuteness" topics

Scenario: Creating a new draft detailed guide related to other detailed guides
  Given a submitted detailed guide "Deep Sea Diving" exists
  When I draft a new detailed guide "Plundering Treasure" related to the detailed guide "Deep Sea Diving"
  Then I should see in the preview that "Plundering Treasure" is related to the detailed guide "Deep Sea Diving"
  And I should see in the preview that "Deep Sea Diving" is related to the detailed guide "Plundering Treasure"

@javascript
Scenario: Adding multiple images
  Given I start drafting a new detailed guide
  When I select an image for the detailed guide
  Then I should be able to select another image for the detailed guide

@javascript
Scenario: Adding multiple attachments
  Given I start drafting a new detailed guide
  When I select an attachment for the detailed guide
  Then I should be able to select another attachment for the detailed guide
