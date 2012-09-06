Feature: Filtering published publications

@javascript
Scenario: The list should only display publications matching the filter
  Given a published publication "Lamb chops on baker's faces" for the organisation "Big co."
  And a published publication "Standard Beard Lengths" for the organisation "Acme"
  When I visit the list of publications
  And I filter to only those from the "Acme" department
  Then I should see the publication "Standard Beard Lengths"
  And I should not see the publication "Lamb chops on baker's faces"

@javascript
Scenario: The list should add pagination
  Given 25 published publications for the organisation "Big co."
  When I visit the list of publications
  And I filter to only those from the "Big co." department
  Then I should see a link to the next page of documents

@javascript
Scenario: The list should tell me how far I am from the end
  Given 25 published publications for the organisation "Big co."
  And 20 published publications for the organisation "Acme"
  When I visit the list of publications
  And I filter to only those from the "Big co." department
  Then I should see that the next page is 2 of 2

@javascript
Scenario: The list should load more when I scroll to the end
  Given 41 published specialist guides for the organisation "Big co."
  When I visit the list of specialist guides
  And I filter to only those from the "Big co." department
  Then I should see 20 documents
  And I scroll to the bottom of the page
  Then I should see 40 documents

@javascript
Scenario: Publication series are included in publication list
  Given a series "Test Series" for the organisation "Acme"
    And a published publication "May 2012 update" in the series "Test Series"
    And 25 published publications for the organisation "Big co."
  When I visit the list of publications
    And I filter to only those from the "Acme" department
  Then I should see the publication "May 2012 Update" belongs to the "Test Series" series
