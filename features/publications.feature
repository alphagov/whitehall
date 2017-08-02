Feature: Publications
  In order to allow the public to view publications
  A writer and editor
  Should be able to draft and publish publications

Background:
  Given I am a writer

Scenario: Creating a new draft publication
  When I draft a new publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of draft documents

Scenario: Creating a new draft publication related to multiple policies
  When I draft a new publication "Healthy Eating" relating it to the policies "Policy 1" and "Policy 2"
  Then the publication should be related to "Policy 1" and "Policy 2" policies

Scenario: Submitting a draft publication to a second pair of eyes
  Given a draft publication "Standard Beard Lengths" exists
  When I submit the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of submitted documents

@not-quite-as-fake-search
Scenario: Publishing a submitted publication
  Given I am an editor
  Given a submitted publication "Standard Beard Lengths" exists
  When I publish the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of published documents
  And the publication "Standard Beard Lengths" should be visible to the public

Scenario: Publishing an edition I submitted is forbidden
  Given I am an editor
  And there is a user called "Beardy"
  And "Beardy" drafts a new publication "Britain's Hairiest Ministers"
  When I submit the publication "Britain's Hairiest Ministers"
  Then I should not be able to publish the publication "Britain's Hairiest Ministers"

@not-quite-as-fake-search
Scenario: Publishing an edition I created but did not submit
  Given I am an editor
  And there is a user called "Beardy"
  And I draft a new publication "Britain's Hairiest Ministers"
  When "Beardy" submits the publication "Britain's Hairiest Ministers"
  And I publish the publication "Britain's Hairiest Ministers"
  Then I should see the publication "Britain's Hairiest Ministers" in the list of published documents

Scenario: Publishing a corporate publication
  Given I am an editor
  And the organisation "Ministry of Hair" exists
  And a submitted corporate publication "Why we care about hair" about the "Ministry of Hair"
  When I publish the publication "Why we care about hair"
  Then I should see "Why we care about hair" is a corporate publication of the "Ministry of Hair"

Scenario: Viewing a publication that's been submitted for review with a PDF attachment
  Given a submitted publication "Legalise beards" with a PDF attachment
  And I am an editor
  When I visit the list of documents awaiting review
  And I view the publication "Legalise beards"
  And I should see a link to the PDF attachment

@not-quite-as-fake-search
Scenario: Viewing published publications
  Given a published publication "Lamb chops on baker's faces" with a PDF attachment
  And a list of publications exists
  When I visit the list of publications
  Then I should see the publication "Lamb chops on baker's faces"
  And I should see the summary of the publication "Lamb chops on baker's faces"

Scenario: Publishing a publication that has a PDF attachment
  Given a published publication "Standard Beard Lengths" with a PDF attachment
  When I visit the publication "Standard Beard Lengths"
  Then I should see a link to the PDF attachment
  And I should see a thumbnail of the first page of the PDF
