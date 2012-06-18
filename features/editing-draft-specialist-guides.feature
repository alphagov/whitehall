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
