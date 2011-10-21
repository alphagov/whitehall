Feature: Publishing news articles

Scenario: Creating a new draft news article
  Given I am a writer
  When I draft a new news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of draft documents

Scenario: Submitting a draft publication to a second pair of eyes
  Given I am a writer
  And a draft news article "Stubble to be Outlawed" exists
  When I submit the news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of submitted documents

Scenario: Publishing a submitted news article
  Given I am an editor
  And a submitted news article "Stubble to be Outlawed" exists
  When I publish the news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of published documents
  And the news article "Stubble to be Outlawed" should be visible to the public
