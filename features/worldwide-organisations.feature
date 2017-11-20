Feature: Administering worldwide organisation
  As a citizen interested in UK gov activity around the world, I want there to
  be profiles of the world organisation (eg embassies, DFID offices, UKTI
  branches) in each worldwide location, so I can see which organisation are
  active in each location and read more about them.

  Acceptance criteria:

  * Each world organisation has:
    * a unique name e.g. "British Embassy in Madrid" and a URL "/world/offices/british-embassy-in-madrid" which is generated from the name
    * multiple social media links (like orgs)
    * multiple sets of office information (like orgs)
      * with the addition of a list of services (chosen from a set) that the office provides
    * a logo formatted name (always using the standard HMG crest for now)
  * Each world organisation can be associated with 1+ world locations, and shows on the world locations page to which they are associated (see mock up on the [ticket](https://www.pivotaltracker.com/story/show/41026113))
  * Each can have corporate information pages (like orgs)

  Background:
    Given I am a GDS editor
    And a world location "United Kingdom" exists

  Scenario: Creating worldwide organisation
    Given the organisation "Department of Beards" exists
    When I create a worldwide organisation "Department of Beards in France" sponsored by the "Department of Beards"
    Then I should see the worldwide organisation information on the public website
    And the "Department of Beards in France" logo should show correctly with the HMG crest
    And I should see that it is part of the "Department of Beards"
    When I update the worldwide organisation to set the name to "Department of Beards and Moustaches in France"
    Then I should see the updated worldwide organisation information on the public website
    When I delete the worldwide organisation
    Then the worldwide organisation should not be visible from the public website

  Scenario: Managing social media links
    Given a worldwide organisation "Department of Beards in France"
    Given a social media service "Twooter"
    When I add a "Twooter" social media link "http://twooter.com/beards-in-france" to the worldwide organisation
    Then the "Twooter" social link should be shown on the public website for the worldwide organisation

  Scenario: Managing office information
    Given a worldwide organisation "Department of Beards in France"
    When I add an "Hair division" office for the home page with address, phone number, and some services
    Then the "Hair division" office details should be shown on the public website
    And I should be able to remove all services from the "Hair division" office

  Scenario: Creating a worldwide organisation in a particular world location
    Given that the world location "France" exists
    When I create a new worldwide organisation "Department of Beards in France" in "France"
    Then I should see the worldwide location name "France" on the worldwide organisation page

  Scenario: Choosing the main office for a worldwide organisation with multiple offices
    Given a worldwide organisation "Department of Beards in France" with offices "Head office" and "Branch office"
    When I choose "Branch office" to be the main office
    Then the "Branch office" should be shown as the main office on the public website
    When I choose "Head office" to be the main office
    Then the "Head office" should be shown as the main office on the public website

  Scenario: Adding default access information to a worldwide organisation
    Given a worldwide organisation "Department of Beards in France" with offices "Head office" and "Branch office"
    When I add default access information to the worldwide organisation
    Then I should see the default access information on the public "Head office" office page
    And I should see the default access information on the public "Branch office" office page

  Scenario: Editing the default access information for a worldwide organisation
    Given a worldwide organisation "Department of Beards in France" with default access information
    When I edit the default access information for the worldwide organisation
    Then I should see the updated default access information

  Scenario: Adding custom access information to a particular worldwide office
    Given a worldwide organisation "Department of Bananas" with default access information
    And the offices "Head office" and "Branch office"
    When I give "Head office" custom access information
    Then I should see the custom access information on the public "Head office" office page
    And I should see the default access information on the public "Branch office" office page

  Scenario: Adding a corporate information page to a worldwide organisation
    Given a worldwide organisation "Department of Beards in France"
    When I add a "Terms of reference" corporate information page to the worldwide organisation
    And I force-publish the "Terms of reference" corporate information page for the worldwide organisation "Department of Beards in France"
    Then I should see the corporate information on the public worldwide organisation page

  Scenario: Adding a new translation
    Given a worldwide organisation "Department of Beards in France" exists for the world location "France" with translations into "Français"
    When I add a new translation to the worldwide organisation "Department of Beards in France" with:
      | locale      | Français                                          |
      | name        | Département des barbes en France                  |
    Then when viewing the worldwide organisation "Department of Beards in France" with the locale "fr" I should see:
      | name        | Département des barbes en France                  |

  Scenario: Editing an existing translation
    Given a worldwide organisation "Department of Beards in France" exists with a translation for the locale "Français"
    When I edit the "Français" translation for the worldwide organisation "Department of Beards in France" setting:
      | name        | Le super département des barbes en France         |
    Then when viewing the worldwide organisation "Department of Beards in France" with the locale "fr" I should see:
      | name        | Le super département des barbes en France         |

  Scenario: Translating a corporate information page for a worldwide organisation
    Given a worldwide organisation "Department of Beards in France"
    And I add a "Terms of reference" corporate information page to the worldwide organisation
    When I translate the "Terms of reference" corporate information page for the worldwide organisation "Department of Beards in France"
    And I force-publish the "Terms of reference" corporate information page for the worldwide organisation "Department of Beards in France"
    Then I should be able to read the translated "Terms of reference" corporate information page for the worldwide organisation "Department of Beards in France" on the site
