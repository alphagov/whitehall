Feature: Corporate Information Pages

Scenario: Adding a corporate information page to an organisation
  Given I am an admin
  And the organisation "Ministry of Pop" exists
  And I add a "Terms of reference" corporate information page to "Ministry of Pop" with body "To support the UK pop music industry"
  When I visit the "Ministry of Pop" organisation
  And I click the "Terms of reference" link
  Then I should see the text "To support the UK pop music industry"

Scenario: Translating a corporate information page for a worldwide organisation
  Given I am a writer
  Given the organisation "Ministry of Pop" exists
  When I add a "Terms of reference" corporate information page to "Ministry of Pop" with body "To support the UK pop music industry"
  And I translate the "Terms of reference" corporate information page for the organisation "Ministry of Pop"
  Then I should be able to read the translated "Terms of reference" corporate information page for the organisation "Ministry of Pop" on the site

Scenario:
  Given I am a writer
  And my organisation has a "Terms of reference" corporate information page
  Then I should be able to add attachments to the "Terms of reference" corporate information page
