Feature: Worldwide offices
  As a citizen interested in UK gov activity around the world, I want there to be profiles of the world offices (eg embassies, DFID offices, UKTI branches) in each worldwide location, so I can see which offices are active in each location and read more about them.

  Acceptance criteria:

  * Each world office has:
    * a unique title e.g. "British Embassy in Madrid" and a URL "/world/offices/british-embassy-in-madrid" which is generated from the title
    * a text short summary and markdown long description.
    * multiple social media links (like orgs)
    * multiple sets of contact information (like orgs)
    * a logo formatted name (always using the standard HMG crest for now)
  * Each world office can be associated with 1+ world locations, and shows on the world locations page to which they are associated (see mock up on the [ticket](https://www.pivotaltracker.com/story/show/41026113))
  * Each can have corporate information pages (like orgs)

  Scenario: Creating worldwide office
    Given I am a GDS editor
    When I create a worldwide office "Department of Beards in France" with a summary and description
    Then I should see the worldwide office on the public website
    And I should see the summary and description on the worldwide office page
    And the "Department of Beards in France" logo should show correctly with the HMG crest

  Scenario: Managing social media links
  Scenario: Managing contact information
  Scenario: Associating world locations with offices
  Scenario: Adding corporate information pages to offices

