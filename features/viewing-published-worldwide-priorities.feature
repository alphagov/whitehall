Feature: Viewing worldwide priorities

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