Feature: Announcing a upcoming statistical release

  As an publisher of government statistics
  I want to be able to announce upcoming statistical publications
  So that citizens can see which statistical publications are coming soon and when they will be published.

  Scenario: announcing a upcoming statistics publication
    Given I am a writer
    When I announce an upcomig statistics publication called "Monthly Beard Stats"
    Then I should see "Monthly Beard Stats" listed as an announced document on my dashboard
