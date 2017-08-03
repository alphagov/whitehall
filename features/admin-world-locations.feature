Feature: Tagging world locations to publications
  As a departmental content editor
  In order to show which location a publication is about
  I want to be able to tag world locations to publications

Scenario: The publication is about a country
  Given I am an editor
  And a world location "British Antarctic Territory" exists
  When I draft a new publication "Penguins have rights too" about the world location "British Antarctic Territory"
  Then the publication should be about the "British Antarctic Territory" world location
