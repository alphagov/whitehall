Feature: Publishing publications
  In order to allow the public to view publications
  A writer and editor
  Should be able to draft and publish publications

Scenario: Creating a new draft publication
  Given I am a writer
  When I draft a new publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of draft documents

Scenario: Creating a new draft publication related to multiple policies
  Given I am a writer
  And two published policies "Totally Tangy Tofu" and "Awakened Tastebuds" exist
  When I draft a new publication "Healthy Eating" relating it to "Totally Tangy Tofu" and "Awakened Tastebuds"
  Then I should see in the preview that "Healthy Eating" should related to "Totally Tangy Tofu" and "Awakened Tastebuds" policies

Scenario: Creating a new draft policy that applies to multiple nations
  Given I am a writer
  When I draft a new publication "Standard Beard Lengths" that does not apply to the nations:
    | Scotland | Wales |
  Then I should see in the preview that "Standard Beard Lengths" does not apply to the nations:
    | Scotland | Wales |

Scenario: Submitting a draft publication to a second pair of eyes
  Given I am a writer
  And a draft publication "Standard Beard Lengths" exists
  When I submit the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of submitted documents

Scenario: Publishing a submitted publication
  Given I am an editor
  And a submitted publication "Standard Beard Lengths" exists
  When I publish the publication "Standard Beard Lengths"
  Then I should see the publication "Standard Beard Lengths" in the list of published documents
  And the publication "Standard Beard Lengths" should be visible to the public