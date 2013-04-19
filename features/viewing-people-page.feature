Feature: Viewing all people page
As a citizen
I want to be able to view a page listing all ministers & senior officials on Inside Government
So that I can find a specific person

Scenario: Viewing all people
  Given "Johnny Macaroon" is the "Minister of Crazy" for the "Department of Woah"
  And "Fred Bloggs" is the "Minister of Sane" for the "Department of Foo"
  When I visit the people page
  Then I should see that "Johnny Macaroon" is listed under "m"
  And I should see that "Fred Bloggs" is listed under "b"
