# encoding: utf-8

Feature: World location news specific to native language speakers

  As an FCO publisher,
  I want the ability to publish a World location news story without having to have an English language edition,
  So that I do not need to spend the time translating content into English

  -------

  Some content is only for audiences local to the location and so an English version is not relevant or desired.

  Background:
    Given I am a GDS editor

  Scenario: Create a world location news article in a non-English language
    Given a world location "France" exists with a translation for the locale "Français"
    When I draft a French-only world location news article associated with "France"
    Then I should see the world location news article listed in admin with an indication that it is in French
    When I publish the French-only world location news article
    Then I should only see the world location news article on the French version of the public "France" location page
    And I should only be able to view the world location news article article in French

  Scenario: Editing a right-to-left non-English edition
    Given a draft right-to-left non-English edition exists
    When I edit the right-to-left non-English edition
    Then I should see that the form text fields are displayed right to left
