Feature: Viewing all people page
As a citizen
I want to be able to view the history and building pages
So that I can learn more about the Government's history and its historic buildings

Scenario: Viewing the history page
  When I visit the history page
  Then I should see historic information

Scenario: Viewing king charles street page
  When I visit the "king charles street" page
  Then I should see historic information about "king charles street"

Scenario: Viewing lancaster house page
  When I visit the "lancaster house" page
  Then I should see historic information about "lancaster house"

Scenario: Viewing 10 downing street page
  When I visit the "10 downing street" page
  Then I should see historic information about "10 downing street"

Scenario: Viewing 11 downing street page
  When I visit the "11 downing street" page
  Then I should see historic information about "11 downing street"

Scenario: Viewing 1 horse guards page
  When I visit the "1 horse guards" page
  Then I should see historic information about "1 horse guards"
