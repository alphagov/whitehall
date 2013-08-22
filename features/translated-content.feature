Feature: Providing translated content from gov.uk/government
  As someone interested in the foreign activities of the UK government who is not a native english speaker
  I want to be able to read information about the UK government in my own language
  So that I can better understand it's relationship to the locales that I am interested in

  Scenario: Maintaining locale between pages
    Given I am viewing a world location that is translated
    When I visit a world organisation associated with that locale that is also translated
    Then I should see the translation of that world organisation

  Scenario: Adding a translation to a draft translatable document
    Given I am a GDS editor
    And I have drafted a translatable document "Military officer exchange"
    When I add a french translation "Échange officier de l'armée" to the "Military officer exchange" document
    Then I should see on the admin edition page that "Military officer exchange" has a french translation "Échange officier de l'armée"
