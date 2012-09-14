Feature: Filtering published policies

@javascript
Scenario: The list should only display policies matching the organisation filter
  Given a published policy "One man went to mow" for the organisation "Big co."
  And a published policy "Standard Beard Lengths" for the organisation "Acme"
  When I visit the list of policies
  And I filter to only those from the "Acme" department
  Then I should see the policy "Standard Beard Lengths"
  And I should not see the policy "One man went to mow"

@javascript
Scenario: The list should only display policies matching the topic filter
  Given two topics "Gardening" and "Formalities" exist
  And a published policy "Improved methods of lawn cultivation" exists in the "Gardening" topic
  And a published policy "Dress codes" exists in the "Formalities" topic
  When I visit the list of policies
  And I filter to only those from the "Formalities" topic
  Then I should see the policy "Dress codes"
  And I should not see the policy "Improved methods of lawn cultivation"

@javascript
Scenario: The list should add pagination
  Given 25 published policies for the organisation "Big co."
  When I visit the list of policies
  And I filter to only those from the "Big co." department
  Then I should see a link to the next page of documents

@javascript
Scenario: The list should tell me how far I am from the end
  Given 25 published policies for the organisation "Big co."
  And 20 published policies for the organisation "Acme"
  When I visit the list of policies
  And I filter to only those from the "Big co." department
  Then I should see that the next page is 2 of 2

@javascript
Scenario: The list should load more when I scroll to the end
  Given 41 published policies for the organisation "Big co."
  When I visit the list of policies
  And I filter to only those from the "Big co." department
  Then I should see 20 documents
  And I scroll to the bottom of the page
  Then I should see 40 documents
