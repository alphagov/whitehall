Feature: editing draft international priorities

Background:
  Given I am a writer

Scenario: Creating a new draft international priority
  When I draft a new international priority "Military officer exchange"
  Then I should see the international priority "Military officer exchange" in the list of draft documents
