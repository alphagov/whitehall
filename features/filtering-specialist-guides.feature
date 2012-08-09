Feature: Filtering published specialist guides

@javascript
Scenario: The list should only display specialist guides matching the filter
  Given a published specialist guide "Lamb chops on baker's faces" for the organisation "Big co."
  And a published specialist guide "Standard Beard Lengths" for the organisation "Acme"
  When I visit the list of specialist guides
  And I filter to only those from the "Acme" department
  Then I should see the specialist guide "Standard Beard Lengths"
  And I should not see the specialist guide "Lamb chops on baker's faces"

@javascript
Scenario: The list should add pagination
  Given 25 published specialist guides for the organisation "Big co."
  When I visit the list of specialist guides
  And I filter to only those from the "Big co." department
  Then I should see a link to the next page of documents

@javascript
Scenario: The list should tell me how far I am from the end
  Given 25 published specialist guides for the organisation "Big co."
  And 20 published specialist guides for the organisation "Acme"
  When I visit the list of specialist guides
  And I filter to only those from the "Big co." department
  Then I should see that the next page is 2 of 2
