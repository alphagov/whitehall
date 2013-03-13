Feature: editing draft publications

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
