Feature: Providing translated content from gov.uk/government
  As someone interested in the foreign activities of the UK government who is not a native english speaker
  I want to be able to read information about the UK government in my own language
  So that I can better understand it's relationship to the locales that I am interested in

  Scenario: Adding a translation to a draft translatable document
    Given I am a GDS editor
    And I have drafted a translatable document "Military officer exchange"
    When I add a french translation "Échange officier de l'armée" to the "Military officer exchange" document
    Then I should see on the admin edition page that "Military officer exchange" has a french translation "Échange officier de l'armée"

  Scenario: Editing a translation for draft translatable document
    Given I am a GDS editor
    And I have drafted a translatable document "Military officer exchange" with a french translation with the title "Échange officier de l'armée"
    When I edit "Military officer exchange"'s french translation's title to "Ministre de l'Éducation nationale"
    Then I should see on the admin edition page that "Military officer exchange" has a french translation "Ministre de l'Éducation nationale"

  Scenario: Deleting a translation for draft translatable document
    Given I am a GDS editor
    And I have drafted a translatable document "Military officer exchange" with a french translation with the title "Échange officier de l'armée"
    When I delete "Military officer exchange"'s french translation
    Then I should see on the admin edition page that "Military officer exchange"'s french translation "Échange officier de l'armée" has been deleted

  Scenario: Adding a translation for contact details
    Given I am a GDS editor
    And the organisation "Wales Office" is translated into Welsh and has a contact "Wales Office, Cardiff"
    When I add a welsh translation "Cysylltwch â ni" to the "Wales Office, Cardiff" contact
    Then I should see on the admin organisation contacts page that "Wales Office, Cardiff" has a welsh translation "Cysylltwch â ni"

  Scenario: Adding a translation for contact details
    Given I am a GDS editor
    When I create a foreign language only document
    And I return to the edit screen
    Then the foreign language only box should be checked
    And if I then un-check the foreign language only box
    Then the edition should return to being an English language only document
    And the foreign translation should be deleted
