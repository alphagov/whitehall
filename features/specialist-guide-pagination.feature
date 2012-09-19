Feature: Paginating long specialist guides
  As a consumer of specialist guides
  I want to be able to navigate easily around the content within a long guide
  So that I can digest it more easily

Scenario: Viewing guides
  Given a specialist guide with section headings
  When I view the specialist guide
  Then I should see all pages of the specialist guide