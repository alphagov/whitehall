Feature: editing draft news articles

Background:
  Given I am a writer

Scenario: Creating a new draft news article
  When I draft a new news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of draft documents

Scenario: Submitting a draft publication to a second pair of eyes
  Given a draft news article "Stubble to be Outlawed" exists
  When I submit the news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of submitted documents