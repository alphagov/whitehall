Feature: Speeches

Scenario: Creating a new edition
  Given I am a writer
  And a published speech exists
  When I create a new edition of the published speech
  And I edit the new edition
  Then the published speech should remain unchanged

  Scenario: Creating a new draft speech
  Given I am a writer
  When I draft a new speech "Outlaw Moustaches"
  Then I should see the speech "Outlaw Moustaches" in the list of draft documents

Scenario: Editing an existing draft speech
  Given I am a writer
  And a draft speech "Outlaw Moustaches" exists
  When I edit the speech "Outlaw Moustaches" changing the title to "Ban Moustaches"
  Then I should see the speech "Ban Moustaches" in the list of draft documents

Scenario: Creating a speech related to multiple policies
  Given I am a writer
  And two published policies "Against All Cods" and "O For Tuna" exist
  When I draft a new speech "Fishy Business" relating it to the policies "Against All Cods" and "O For Tuna"
  Then I should see in the preview that "Fishy Business" should related to "Against All Cods" and "O For Tuna" policies

Scenario: Creating a speech related to multiple worldwide prioirites
  Given I am a writer
  And a published worldwide priority "Fish Exchange Programme" exists
  And a published worldwide priority "Supporting British Fish Abroad" exists
  When I draft a new speech "Fishy Business" relating it to the worldwide_priorities "Fish Exchange Programme" and "Supporting British Fish Abroad"
  Then I should see in the preview that "Fishy Business" should related to "Fish Exchange Programme" and "Supporting British Fish Abroad" worldwide priorities

Scenario: Trying to save a speech that has been changed by another user
  Given I am a writer
  And a draft speech "Outlaw Moustaches" exists
  And I start editing the speech "Outlaw Moustaches" changing the title to "Ban Moustaches"
  And another user edits the speech "Outlaw Moustaches" changing the title to "Ban Beards"
  When I save my changes to the speech
  Then I should see the conflict between the speech titles "Ban Moustaches" and "Ban Beards"
  When I edit the speech changing the title to "Ban Moustaches and Beards"
  Then I should see the speech "Ban Moustaches and Beards" in the list of draft documents

Scenario: Submitting a draft speech to a second pair of eyes
  Given I am a writer
  And a draft speech "Outlaw Moustaches" exists
  When I submit the speech "Outlaw Moustaches"
  Then I should see the speech "Outlaw Moustaches" in the list of submitted documents

Scenario: Viewing a speech that's been submitted for review
  Given "Ben Beardson" submitted a speech "Legalise beards" with body "Beards for everyone!"
  When I visit the list of speeches awaiting review
  And I view the speech "Legalise beards"
  And I should see that "Beards for everyone!" is the speech body

@not-quite-as-fake-search
Scenario: Publishing a submitted speech
  Given I am an editor
  And a submitted speech "Stubble to be Outlawed" exists
  When I publish the speech "Stubble to be Outlawed"
  Then I should see the speech "Stubble to be Outlawed" in the list of published documents
  And the speech "Stubble to be Outlawed" should be visible to the public

@javascript
Scenario: Creating authored articles (originally published externally)
  Given I am an editor
  When I draft a new authored article "Colonel Mustard talks about beards to The Times"
  Then I should be able to choose who wrote the article
  And I should be able to choose the date it was written on
  But I cannot choose a location for the article

Scenario: Viewing authored articles (originally published externally)
  Given I am an editor
  When I draft a new authored article "Colonel Mustard talks about beards to The Times"
  Then it should be shown as an authored article in the admin screen
  When I preview the authored article
  Then I should see who wrote it clearly labelled in the metadata

@not-quite-as-fake-search
Scenario: Publishing a submitted speech
  Given I am an editor
  And a submitted speech "Stubble to be Outlawed" exists
  When I publish the speech "Stubble to be Outlawed"
  Then I should see the speech "Stubble to be Outlawed" in the list of published documents
  And the speech "Stubble to be Outlawed" should be visible to the public

Scenario: Viewing speeches made by a minister
  Given "David Cameron" is the "Prime Minister" for the "Cabinet Office"
  And a published speech "Abolish Fig Rolls" by "Prime Minister" on "June 23rd, 2010" at "The Mansion House"
  When I visit the minister page for "Prime Minister"
  Then I should see the speech "Abolish Fig Rolls"
  When I visit the speech "Abolish Fig Rolls"
  Then I should see the speech was delivered on "23 June 2010" at "The Mansion House"

Scenario: Viewing a published speech with related policies
  Given a published speech "Things I Have Thought" with related published policies "Policy 1" and "Policy 2"
  When I visit the speech "Things I Have Thought"
  Then I can see links to the related published policies "Policy 1" and "Policy 2"
