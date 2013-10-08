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

  Scenario: Adding a translation for contact details
    Given I am a GDS editor
    And the organisation "Wales Office" has a contact "Wales Office, Cardiff"
    When I add a welsh translation "Cysylltwch â ni" to the "Wales Office, Cardiff" contact
    Then I should see on the admin organisation contacts page that "Wales Office, Cardiff" has a welsh translation "Cysylltwch â ni"

  Scenario: Adding a translation for worldwide offices
    Given I am a GDS editor
    And the world organisation "British Embassy, Paris" has an office "British Consulate-General Paris"
    When I add a french translation "Consulat Général du Royaume-Uni à Paris" to the "British Consulate-General Paris" office
    Then I should see on the admin world organisation offices page that "British Consulate-General Paris" has a french translation "Consulat Général du Royaume-Uni à Paris"
