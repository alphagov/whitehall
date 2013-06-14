Feature: Admin Dashboard

  As an admin user
  I want to be able to see relevent information about me and my department on a
  dashboard when I log into the admin
  So that I can see if there are things that need my attention or things I have
  to work on.

  Background:
    Given I am an editor in the organisation "MOD"

  @javascript
  Scenario: Loading the dashboard
    Given a force published document "forced document" was produced by the "MOD" organisation
    When I draft a new news article "draft document"
    And I visit the admin dashboard
    Then I should see the draft document "draft document"
    And I should see the force published document "forced document"
