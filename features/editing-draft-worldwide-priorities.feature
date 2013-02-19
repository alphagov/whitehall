Feature: editing draft worldwide priorities

Background:
  Given I am a writer

Scenario: Creating a new draft worldwide priority
  When I draft a new worldwide priority "Military officer exchange"
  Then I should see the worldwide priority "Military officer exchange" in the list of draft documents

Scenario: Adding a translation to a draft worldwide priority
  Given I have drafted a worldwide priority "Military officer exchange"
  When I add a french translation "Échange officier de l'armée" to the "Military officer exchange" worldwide priority
  Then I should see in the preview that "Military officer exchange" has a french translation "Échange officier de l'armée"