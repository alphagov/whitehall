Feature: Paginating long detailed guides
  As a consumer of detailed guides
  I want to be able to navigate easily around the content within a long guide
  So that I can digest it more easily

Scenario: Viewing guides
  Given a detailed guide with section headings
  When I view the detailed guide
  Then I should see all pages of the detailed guide
