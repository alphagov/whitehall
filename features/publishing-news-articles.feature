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

Scenario: Creating a news article related to multiple policies
  Given I am a writer
  And two published policies "Totally Tangy Tofu" and "Awakened Tastebuds" exist
  When I draft a new news article "Healthy Eating" relating it to "Totally Tangy Tofu" and "Awakened Tastebuds"
  Then I should see in the preview that "Healthy Eating" should related to "Totally Tangy Tofu" and "Awakened Tastebuds" policies