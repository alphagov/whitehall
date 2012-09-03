Feature: Filtering published announcements

@javascript
Scenario: The list should only display announcements matching the organisation filter
  Given a published speech "One man went to mow" for the organisation "Big co."
  And a published news article "Standard Beard Lengths" for the organisation "Acme"
  When I visit the list of announcements
  And I filter to only those from the "Acme" department
  Then I should see the announcement "Standard Beard Lengths"
  And I should not see the announcement "One man went to mow"

@javascript
Scenario: The list should only display announcements matching the topic filter
  Given two topics "Gardening" and "Formalities" exist
  And a published policy "Improved methods of lawn cultivation" exists in the "Gardening" topic
  And a published policy "Dress codes" exists in the "Formalities" topic
  And a published speech "One man went to mow" for the policy "Improved methods of lawn cultivation"
  And a published news article "Standard Beard Lengths" for the policy "Dress codes"
  When I visit the list of announcements
  And I filter to only those from the "Formalities" topic
  Then I should see the announcement "Standard Beard Lengths"
  And I should not see the announcement "One man went to mow"

@javascript
Scenario: The list should add pagination
  Given 25 published speeches for the organisation "Big co."
  When I visit the list of announcements
  And I filter to only those from the "Big co." department
  Then I should see a link to the next page of documents

@javascript
Scenario: The list should tell me how far I am from the end
  Given 25 published speeches for the organisation "Big co."
  And 20 published speeches for the organisation "Acme"
  When I visit the list of announcements
  And I filter to only those from the "Big co." department
  Then I should see that the next page is 2 of 2

@javascript
Scenario: The list should load more when I scroll to the end
  Given 41 published speeches for the organisation "Big co."
  When I visit the list of announcements
  And I filter to only those from the "Big co." department
  Then I should see 20 documents
  And I scroll to the bottom of the page
  Then I should see 40 documents
