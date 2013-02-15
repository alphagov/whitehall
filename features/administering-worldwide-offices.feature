Feature: Administering worldwide offices
  As a citizen interested in UK gov activity around the world, I want there to be profiles of the world offices (eg embassies, DFID offices, UKTI branches) in each worldwide location, so I can see which offices are active in each location and read more about them.

  Acceptance criteria:

  * Each world office has:
    * a unique name e.g. "British Embassy in Madrid" and a URL "/world/offices/british-embassy-in-madrid" which is generated from the name
    * a text short summary and markdown long description.
    * multiple social media links (like orgs)
    * multiple sets of contact information (like orgs)
    * a logo formatted name (always using the standard HMG crest for now)
  * Each world office can be associated with 1+ world locations, and shows on the world locations page to which they are associated (see mock up on the [ticket](https://www.pivotaltracker.com/story/show/41026113))
  * Each can have corporate information pages (like orgs)

  Background:
    Given I am a GDS editor

  Scenario: Creating worldwide office
    Given the organisation "Department of Beards" exists
    When I create a worldwide office "Department of Beards in France" sponsored by the "Department of Beards" with a summary, description and services
    Then I should see the worldwide office information on the public website
    And the "Department of Beards in France" logo should show correctly with the HMG crest
    And I should see that it is part of the "Department of Beards"
    When I update the worldwide office to set the name to "Department of Beards and Moustaches in France"
    Then I should see the updated worldwide office information on the public website
    When I delete the worldwide office
    Then the worldwide office should not be visible from the public website

  Scenario: Managing social media links
    Given a worldwide office "Department of Beards in France"
    Given a social media service "Twooter"
    When I add a "Twooter" social media link "http://twooter.com/beards-in-france"
    Then the social link should be shown on the public website

  Scenario: Managing contact information
    Given a worldwide office "Department of Beards in France"
    When I add an "Hair division" contact with address and phone number
    Then the "Hair division" details should be shown on the public website

  Scenario: Creating a worldwide office in a particular world location
    Given that the world location "France" exists
    When I create a new worldwide office "Department of Beards in France" in "France"
    Then I should see the worldwide office "Department of Beards in France" on the "France" world location page

  Scenario: Choosing the main contact for a worldwide office with multiple contacts
    Given a worldwide office "Department of Beards in France" with contacts "Head office" and "Branch office"
    When I choose "Branch office" to be the main contact
    Then the "Branch office" should be shown as the main contact on the public website
    When I choose "Head office" to be the main contact
    Then the "Head office" should be shown as the main contact on the public website

  Scenario: Creating a worldwide office in particular world location with a sponsor
    Given the organisation "Department of Beards" exists
    Given that the world location "France" exists
    When I create a new worldwide office "Department of Beards in France" in  "France" sponsored by the "Department of Beards"
    Then I should see the worldwide office "Department of Beards in France" on the "France" world location page
    And I should see that it is part of the "Department of Beards"

  Scenario: Adding office hours to a worldwide office
  Scenario: Adding corporate information pages to offices
