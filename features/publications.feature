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
  Given two published policies "Totally Tangy Tofu" and "Awakened Tastebuds" exist
  When I draft a new publication "Healthy Eating" relating it to the policies "Totally Tangy Tofu" and "Awakened Tastebuds"
  Then I should see in the preview that "Healthy Eating" should related to "Totally Tangy Tofu" and "Awakened Tastebuds" policies

Scenario: Creating a publication related to multiple worldwide prioirites
  Given a published worldwide priority "Fish Exchange Programme" exists
  And a published worldwide priority "Supporting British Fish Abroad" exists
  When I draft a new publication "Fishy Business" relating it to the worldwide_priorities "Fish Exchange Programme" and "Supporting British Fish Abroad"
  Then I should see in the preview that "Fishy Business" should related to "Fish Exchange Programme" and "Supporting British Fish Abroad" worldwide priorities

Scenario: Creating a new draft publication that applies to multiple nations
  Given I draft a new publication "Standard Beard Lengths" that does not apply to the nations:
    | Scotland | Wales |
  Then I should see in the preview that "Standard Beard Lengths" does not apply to the nations:
    | Scotland | Wales |

Scenario: Creating a new draft publication that references statistical data sets
    Given I am an editor
    Given a published statistical data set "Historical Beard Lengths"
    When I draft a new publication "Beard Lengths 2012" referencing the data set "Historical Beard Lengths"
    Then I should see in the preview that "Beard Lengths 2012" is taken from the live data in "Historical Beard Lengths"

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
  When I visit the list of publications
  Then I should see the publication "Lamb chops on baker's faces"
  And I should see the summary of the publication "Lamb chops on baker's faces"

Scenario: Publishing a publication that has a PDF attachment
  Given a published publication "Standard Beard Lengths" with a PDF attachment
  When I visit the publication "Standard Beard Lengths"
  Then I should see a link to the PDF attachment
  And I should see a thumbnail of the first page of the PDF

Scenario: The publication is about a country
  Given a world location "British Antarctic Territory" exists
  And a published publication "Penguins have rights too" exists that is about "British Antarctic Territory"
  When I visit the publication "Penguins have rights too"
  Then I should see that the publication is about "British Antarctic Territory"
