Feature: Services and information page for organisations

Background:
  Given the organisation "Cabinet Office" exists

Scenario: Organisation page links to a services and information page for that org
  When I visit the "Cabinet Office" organisation
  Then I can see a link to a "Full list of topics" for the "Cabinet Office" organisation

@not-quite-as-fake-search
Scenario: Viewing the services and information page for an org
  When I visit the "Cabinet Office" organisation
  And I click the link to the full list of topics for that organisation
  Then I should see a list of documents related to the Cabinet Office org grouped by sector
