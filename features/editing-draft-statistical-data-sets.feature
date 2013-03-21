Feature: Editing draft statistical data sets

  More scenarios need to be added to this in due course - we are
  currently writing the feature to test a specific bug fix.

Background:
  Given I am a writer in the organisation "Ministry of Grooming"

Scenario: Creating a new draft statistical data set
  When I draft a new statistical data set "Standard Beard Lengths" for organisation "Ministry of Grooming"
  Then I should see the statistical data set "Standard Beard Lengths" in the list of draft documents
