Feature: Viewing international priorities

Scenario: Viewing an international priority in another language
  Given an international priority which is available in english as "Priority for Spain" and in spanish as "Prioridad para España"
  When I view the international priority "Priority for Spain"
  Then I should be able to navigate to the spanish translation "Prioridad para España"
  And I should be able to navigate to the english translation "Priority for Spain"
