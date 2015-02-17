Feature: governments

As an editor
I want to be able to associate content with a specific government
So that we can appropriately identify less relevant content after elections.

Scenario: creating a government
  Given I am a GDS editor
  When I create a government called "2005 to 2010 Labour government" between dates "06/05/2005" and "11/05/2010"
  Then there should be a government called "2005 to 2010 Labour government" between dates "2005-05-06" and "2010-05-11"
