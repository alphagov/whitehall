# encoding: utf-8

Feature: World location news specific to native language speakers

  As an FCO publisher,
  I want the ability to publish a World location news story without having to have an English language edition,
  So that I do not need to spend the time translating content into English

  -------

  Some content is only for audiences local to the location and so an English version is not relevant or desired.

  Scenario: Create a world location news article in a non-English language
    Given I am an GDS editor
    And a world location "France" exists with a translation for the locale "Français"
    When I draft a French-only world location news article called "Le ministre de la Funk aime faire la fête" associated with "France"
    Then I should see the "Le ministre de la Funk aime faire la fête" article listed in admin with an indication that it is in French
    When I publish the non-English world location news article "Le ministre de la Funk aime faire la fête"
    Then I should see the "Le ministre de la Funk aime faire la fête" article on the French version of the public "France" location page
    And I should be able to view the article "Le ministre de la Funk aime faire la fête" article in French
    But I shoud not see the "Le ministre de la Funk aime faire la fête" article on the English version of the public "France" location page