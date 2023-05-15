@design-system-only
Feature: Reordering of Cabinet ministers and Organisations
  As a GDS editor
  I want to be able to able to view and reorder Cabinet minsters and Organisations
  So that I can reflect Cabinet reshuffles

  Background:
    Given I am a GDS editor

  Scenario: Reordering Cabinet ministers
    Given there are multiple Cabinet minister roles
    When I visit the Cabinet ministers order page
    And I click the reorder link in the "#cabinet_minister" tab
    And I set the order of the roles for the "roles" ordering field to:
      | name   | order |
      | Role 2 | 0     |
      | Role 1 | 1     |
    Then the roles in the "#cabinet_minister" tab should be in the following order:
      | name   |
      | Role 2 |
      | Role 1 |

  Scenario: Reordering Also attends cabinet roles
    Given there are multiple Also attends cabinet roles
    When I visit the Cabinet ministers order page
    And I click the reorder link in the "#also_attends_cabinet" tab
    And I set the order of the roles for the "roles" ordering field to:
      | name   | order |
      | Role 2 | 0     |
      | Role 1 | 1     |
    Then the roles in the "#also_attends_cabinet" tab should be in the following order:
      | name   |
      | Role 2 |
      | Role 1 |

  Scenario: Reordering Whip roles
    Given there are multiple Whip roles
    When I visit the Cabinet ministers order page
    And I click the reorder link in the "#whips" tab
    And I set the order of the roles for the "whips" ordering field to:
      | name   | order |
      | Role 2 | 0     |
      | Role 1 | 1     |
    Then the roles in the "#whips" tab should be in the following order:
      | name   |
      | Role 2 |
      | Role 1 |
