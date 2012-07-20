Feature: Editing draft specialist guide

Background:
  Given I am a writer

Scenario: Creating a new draft specialist guide
  When I draft a new specialist guide "The finer points of moustache trimming"
  Then I should see the specialist guide "The finer points of moustache trimming" in the list of draft documents

Scenario: Creating a new draft specialist guide in multiple topics
  Given two topics "Facial Hair" and "Hirsuteness" exist
  When I draft a new specialist guide "Outlaw Moustaches" in the "Facial Hair" and "Hirsuteness" topics
  Then I should see in the preview that "Outlaw Moustaches" should be in the "Facial Hair" and "Hirsuteness" topics

Scenario: Creating a new draft specialist guide related to other specialist guides
  Given a submitted specialist guide "Deep Sea Diving" exists
  When I draft a new specialist guide "Plundering Treasure" related to the specialist guide "Deep Sea Diving"
  Then I should see in the preview that "Plundering Treasure" is related to the specialist guide "Deep Sea Diving"
  And I should see in the preview that "Deep Sea Diving" is related to the specialist guide "Plundering Treasure"

@javascript
Scenario: Adding multiple images
  Given I start drafting a new specialist guide
  When I select an image for the specialist guide
  Then I should be able to select another image for the specialist guide

@javascript
Scenario: Adding multiple attachments
  Given I start drafting a new specialist guide
  When I select an attachment for the specialist guide
  Then I should be able to select another attachment for the specialist guide