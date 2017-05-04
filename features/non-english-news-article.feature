# encoding: utf-8

Feature: News article specific to native language speakers

  As an publisher dealing with world wide content (eg FCO),
  I want the ability to publish a News article without having to have an English language edition,
  So that I do not need to spend the time translating content into English

  -------

  Some content is only for audiences local to the location and so an English version is not relevant or desired.

  Background:
    Given I am a GDS editor

  Scenario: Create a News article in a non-English language
    Given a world location "France" exists with a translation for the locale "Français"
    When I draft a French-only news article associated with "France"
    Then I should see the news article listed in admin with an indication that it is in French
    When I publish the French-only news article
    Then I should only see the news article on the French version of the public "France" location page
