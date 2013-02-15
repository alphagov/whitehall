Feature: Viewing international priorities

Scenario: Viewing an international priority in another language
  Given an international priority which is available in english as "Priority for Spain" and in spanish as "Prioridad para España"
  When I view the international priority "Priority for Spain"
  Then I should be able to navigate to the spanish translation "Prioridad para España"
  And I should be able to navigate to the english translation "Priority for Spain"

Scenario: Viewing an international priority associated with a worldwide office
  Given the worldwide office "Embassy in Spain" exists
  And a published international priority "Oil field exploitation" exists relating to the worldwide office "Embassy in Spain"
  When I view the international priority "Oil field exploitation"
  Then I should see the worldwide office listed on the page