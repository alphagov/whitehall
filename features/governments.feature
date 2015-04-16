Feature: governments

As an editor
I want to be able to associate content with a specific government
So that we can appropriately identify less relevant content after elections.

Scenario: creating a government
  Given I am a GDS admin
  When I create a government called "2005 to 2010 Labour government" starting on "06/05/2005"
  Then there should be a government called "2005 to 2010 Labour government" starting on "2005-05-06"

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
  Then there should be a government called "2005 to 2010 Labour government" between dates "2005-05-06" and "2010-05-11"

Scenario: changing government after an election
  Given there is a current government
  And I am a GDS admin
  When I close the current government
  And I create a government called "Robo-alien Overlords"
  Then the current government should be "Robo-alien Overlords"
