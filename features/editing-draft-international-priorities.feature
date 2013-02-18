Feature: editing draft international priorities

Background:
  Given I am a writer

Scenario: Creating a new draft international priority
  When I draft a new international priority "Military officer exchange"
  Then I should see the international priority "Military officer exchange" in the list of draft documents

Scenario: Adding a translation to a draft international priority
  Given I have drafted an international priority "Military officer exchange"
  When I add a french translation "Échange officier de l'armée" to the "Military officer exchange" international priority
  Then I should see in the preview that "Military officer exchange" has a french translation "Échange officier de l'armée"