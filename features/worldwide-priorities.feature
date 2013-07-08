Feature: Worldwide priorities

Scenario: Viewing a worldwide priority in another language
  Given a worldwide priority which is available in english as "Priority for Spain" and in spanish as "Prioridad para España"
  When I view the worldwide priority "Priority for Spain"
  Then I should be able to navigate to the spanish translation "Prioridad para España"
  And I should be able to navigate to the english translation "Priority for Spain"

Scenario: Viewing a worldwide priority associated with a worldwide organisation
  Given the worldwide organisation "Embassy in Spain" exists
  And a published worldwide priority "Oil field exploitation" exists relating to the worldwide organisation "Embassy in Spain"
  When I view the worldwide priority "Oil field exploitation"
  Then I should see the worldwide organisation listed on the page

Scenario: Viewing the activity around a worldwide priority
  Given a published worldwide priority "Unicorn research" exists
  And a published publication "Adventures in unicorn breeding" related to the priority "Unicorn research"
  And a published consultation "Optimum unicorn horn length" related to the priority "Unicorn research"
  And a published news article "Latest unicorn sightings reported" related to the priority "Unicorn research"
  And a published speech "Unicorns and our future: Mark Web" related to the priority "Unicorn research"
  When I visit the activity of the published priority "Unicorn research"
  Then I can see links to the recently changed document "Adventures in unicorn breeding"
  And I can see links to the recently changed document "Optimum unicorn horn length"
  And I can see links to the recently changed document "Latest unicorn sightings reported"
  And I can see links to the recently changed document "Unicorns and our future: Mark Web"

Scenario: Publishing a submitted worldwide priority
  Given I am a GDS editor
  And a submitted worldwide priority "Military officer exchange" exists
  When I publish the worldwide priority "Military officer exchange"
  Then I should see the worldwide priority "Military officer exchange" in the list of published documents
  And the worldwide priority "Military officer exchange" should be visible to the public

Scenario: Creating a new draft worldwide priority
  Given I am a GDS editor
  When I draft a new worldwide priority "Military officer exchange"
  Then I should see the worldwide priority "Military officer exchange" in the list of draft documents
