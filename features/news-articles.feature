Feature: News articles

Scenario: Creating a new draft news article
  Given I am a writer
  When I draft a new news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of draft documents

Scenario: Submitting a draft publication to a second pair of eyes
  Given I am a writer
  And a draft news article "Stubble to be Outlawed" exists
  When I submit the news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of submitted documents

Scenario: Viewing associated people on news articles not roles
  Given I am an editor
  And "Don Deputy" is the "Deputy Prime Minister" for the "Cabinet Office"
  And "Harriet Home" is the "Home Secretary" for the "Cabinet Office"
  When I publish a news article "News 1" associated with "Don Deputy"
  When there is a reshuffle and "Harriet Home" is now "Deputy Prime Minister"
  And I visit the news article "News 1"
  Then the article mentions "Don Deputy" and links to their bio page
  And the news article tag is the same as the person in the text

Scenario: Lead image automatically selected as first uploaded image
  Given I am an editor
  When I draft a new news article "Stubble to be Outlawed"
  Then I should see the first uploaded image used as the lead image
  And if no image is uploaded a default image is shown

Scenario: First image not allowed in markdown
  Given I am a writer
  When I draft a new news article "Stubble to be Outlawed"
  Then I should be informed I shouldn't use this image in the markdown
  When I attempt to add the article image into the markdown
  Then my attempt to save it should fail with error "first image"

@not-quite-as-fake-search
Scenario: Publishing a submitted news article
  Given I am an editor
  And a submitted news article "Stubble to be Outlawed" exists
  When I publish the news article "Stubble to be Outlawed"
  Then I should see the news article "Stubble to be Outlawed" in the list of published documents
  And the news article "Stubble to be Outlawed" should be visible to the public

Scenario: Creating a news article related to multiple policies
  Given I am a writer
  And two published policies "Totally Tangy Tofu" and "Awakened Tastebuds" exist
  When I draft a new news article "Healthy Eating" relating it to the policies "Totally Tangy Tofu" and "Awakened Tastebuds"
  Then I should see in the preview that "Healthy Eating" should related to "Totally Tangy Tofu" and "Awakened Tastebuds" policies

Scenario: Creating a news article related to multiple worldwide prioirites
  Given a published worldwide priority "Fish Exchange Programme" exists
  And a published worldwide priority "Supporting British Fish Abroad" exists
  When I draft a new news article "Fishy Business" relating it to the worldwide_priorities "Fish Exchange Programme" and "Supporting British Fish Abroad"
  Then I should see in the preview that "Fishy Business" should related to "Fish Exchange Programme" and "Supporting British Fish Abroad" worldwide priorities

Scenario: Viewing a published news article with related policies
  Given a published news article "News 1" with related published policies "Policy 1" and "Policy 2"
  When I visit the news article "News 1"
  Then I can see links to the related published policies "Policy 1" and "Policy 2"

@javascript
Scenario: Changes on an edition are not lost when adding attachments
  Given I am a writer
  And a draft news article "Stubble to be Outlawed" exists
  When I make unsaved changes to the news article
  And I attempt to visit the attachments page
  Then I should stay on the edit screen for the news article
  When I save my changes
  Then I can visit the attachments page
