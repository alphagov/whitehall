Feature: Redirecting short vanity URLs for departments

As a department, 
I want a short URL at the root of gov.uk - e.g. gov.uk/bis 
So I can see how I will be able to market my org's homepage with a snappy URL in future

Scenario: Redirecting /bis
  Given the organisation "Department for Business, Innovation and Skills" exists
  When I visit "/bis"
  Then I should see the "Department for Business, Innovation and Skills" organisation's home page
