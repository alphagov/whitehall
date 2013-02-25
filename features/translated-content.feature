Feature: Providing translated content from gov.uk/government
  As someone interested in the foreign activities of the UK government who is not a native english speaker
  I want to be able to read information about the UK government in my own language
  So that I can better understand it's relationship to the locales that I am interested in

  Scenario: Maintaining locale between pages
    Given I am viewing a world location that is translated
    When I visit a world organisation associated with that locale that is also translated
    Then I should see the translation of that world organisation
