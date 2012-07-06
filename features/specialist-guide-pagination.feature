@javascript
Feature: Paginating long specialist guides
  As a consumer of specialist guides
  I want to be able to navigate easily around the content within a long guide
  So that I can digest it more easily

 Scenario: Break the guide up into pages
   Given a paginated specialist guide with section headings
   When I view the specialist guide
   Then I should see only the first page of the specialist guide

   When I navigate to the second page of the specialist guide
   Then I should see only the second page of the specialist guide
   And I should see the URL fragment for the second page of the specialist guide in my browser address bar

   When I navigate to the next page of the specialist guide
   Then I should see only the third page of the specialist guide
   And I should see the URL fragment for the third page of the specialist guide in my browser address bar

 Scenario: Show the summary on all pages
   Given a paginated specialist guide with section headings
   When I view the first page of the specialist guide
   Then I should see the specialist guide summary

   When I navigate to the second page of the specialist guide
   Then I should see the specialist guide summary

 Scenario: Navigate within a page
   Given a paginated specialist guide with section headings
   When I view the first page of the specialist guide
   Then I should not see navigation for headings within other specialist guide pages

   When I view a specialist guide page with internal headings
   Then I should see navigation for the headings within that specialist guide page

   When I navigate to a heading within the specialist guide page
   Then I should see the URL fragment for the specialist guide heading in my browser address bar

 Scenario: Visiting bookmarked links to a page
   Given a paginated specialist guide with section headings
   When I visit the URL for the second page of the specialist guide
   Then I should see only the second page of the specialist guide

 Scenario: Visiting bookmarked links within a page
   Given a paginated specialist guide with section headings
   When I visit the URL for a heading within the second page of the specialist guide
   Then I should see only the second page of the specialist guide

 Scenario: Viewing non-paginated guides
   Given a non-paginated specialist guide with section headings
   When I view the specialist guide
   Then I should see all pages of the specialist guide