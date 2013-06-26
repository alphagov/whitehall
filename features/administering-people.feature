Feature: administer people who can hold ministerial/other roles

Background:
  Given I am an admin

Scenario: Adding a person
  When I add a new person called "Dave Cameroon"
  Then I should be able to see "Dave Cameroon" in the list of people

Scenario: Editing a person
  Given a person called "Dave Camerine"
  When I update the person called "Dave Camerine" to have the name "Nick Clogg"
  Then I should be able to see "Nick Clogg" in the list of people

Scenario: Removing a person
  Given a person called "Liam Fixx"
  When I remove the person "Liam Fixx"
  Then I should not be able to see "Liam Fixx" in the list of people

Scenario: Adding a new translation
  Given a person called "Amanda Appleford" exists with the biography "She was born. She lived. She died."
  When I add a new "Français" translation to the person "Amanda Appleford" with:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |
  Then when viewing the person "Amanda Appleford" with the locale "Français" I should see:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |

Scenario: Editing an existing translation
  Given a person called "Amanda Appleford" exists with a translation for the locale "Français"
  When I edit the "Français" translation for the person called "Amanda Appleford" setting:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |
  Then when viewing the person "Amanda Appleford" with the locale "Français" I should see:
    | biography         | Elle est née. Elle a vécu. Elle est morte.                  |

Scenario: Images are virus-checked before publication
  When I add a new person called "Dave Cameroon"
  Then the image will be quarantined for virus checking
  When the image has been virus-checked
  Then the virus checked image will be available for viewing

