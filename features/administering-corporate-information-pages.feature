Feature: Administering Corporate Information Pages

Scenario: Adding a corporate information page
  Given I am an admin
  And the organisation "Ministry of Pop" exists
  And I add a "Terms of reference" corporate information page to "Ministry of Pop" with body "To support the UK pop music industry"
  When I visit the "Ministry of Pop" organisation
  And I click the "Terms of reference" link
  Then I should see the text "To support the UK pop music industry"
