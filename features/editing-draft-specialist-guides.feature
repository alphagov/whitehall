Feature: Editing draft specialist guide

Background:
  Given I am a writer

Scenario: Creating a new draft specialist guide
  When I draft a new specialist guide "The finer points of moustache trimming"
  Then I should see the specialist guide "The finer points of moustache trimming" in the list of draft documents
