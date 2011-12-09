Feature: editing draft publications

Background:
  Given I am a writer

Scenario: Creating a new draft publication
  When I draft a new publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of draft documents

Scenario: Creating a new draft publication related to multiple policies
  Given two published policies "Totally Tangy Tofu" and "Awakened Tastebuds" exist
  When I draft a new publication "Healthy Eating" relating it to "Totally Tangy Tofu" and "Awakened Tastebuds"
  Then I should see in the preview that "Healthy Eating" should related to "Totally Tangy Tofu" and "Awakened Tastebuds" policies

Scenario: Creating a new draft publication that applies to multiple nations
  Given I draft a new publication "Standard Beard Lengths" that does not apply to the nations:
    | Scotland | Wales |
  Then I should see in the preview that "Standard Beard Lengths" does not apply to the nations:
    | Scotland | Wales |

Scenario: Submitting a draft publication to a second pair of eyes
  Given a draft publication "Standard Beard Lengths" exists
  When I submit the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of submitted documents