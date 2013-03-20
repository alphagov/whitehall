Feature: editing draft worldwide priorities

Background:
  Given I am a GDS editor

Scenario: Creating a new draft worldwide priority
  When I draft a new worldwide priority "Military officer exchange"
  Then I should see the worldwide priority "Military officer exchange" in the list of draft documents
