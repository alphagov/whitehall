Feature: governments

  As an editor
  I want to be able to associate content with a specific government
  So that we can appropriately identify less relevant content after elections.

  Scenario: creating a government
    Given I am a GDS admin
    When I create a government called "2005 to 2010 Labour government" starting on "06/05/2005"
    Then there should be a government called "2005 to 2010 Labour government" starting on "6 May 2005"

  Scenario: ending a government
    Given there is a current government
    And two cabinet ministers "Alice" and "Ben"
    And I am a GDS admin
    When I close the current government
    Then there should be no active ministerial role appointments

  Scenario: editing a government's start and end dates
    Given a government exists called "2005 to 2010 Labour government" between dates "06/05/2004" and "11/05/2009"
    And I am a GDS admin
    When I edit the government called "2005 to 2010 Labour government" to have dates "06/05/2005" and "11/05/2010"
    Then there should be a government called "2005 to 2010 Labour government" between dates "6 May 2005" and "11 May 2010"

  Scenario: changing government after an election
    Given there is a current government
    And I am a GDS admin
    When I close the current government
    And I create a government called "Robo-alien Overlords"
    Then the current government should be "Robo-alien Overlords"

  Scenario: appointing a minister to the new government
    Given I am a GDS admin
    And a person called "Fred Fancy"
    And "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
    And there is a current government
    When I close the current government
    And I create a government called "Robo-alien Overlords"
    And I appoint "Fred Fancy" as the "Minister of Crazy"
    Then I should be able to create a news article associated with "Fred Fancy" as the "Minister of Crazy"

  @design-system-only
  Scenario: There are no governments available to view
    Given that there no governments available to view
    And I am a GDS admin
    When I visit the governments page
    Then I should see no governments message
