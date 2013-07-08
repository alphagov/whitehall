Feature: Cabinet Office ministers and Whips

  As the No 10/Cabinet Office digital team
  We want curate the order in which ministers are listed in the Cabinet
  section of the ministers page and in the whips section
  So that the seniority of members of cabinet and whips are accurately
  reflected

  Scenario: Administering the order of cabinet ministers
    Given I am a GDS editor called "Jane"
    And two cabinet ministers "Mary Moffet" and "Catherine Tuffet"
    When I order the cabinet ministers "Mary Moffet", "Catherine Tuffet"
    Then I should see "Mary Moffet", "Catherine Tuffet" in that order on the ministers page
    When I order the cabinet ministers "Catherine Tuffet", "Mary Moffet"
    Then I should see "Catherine Tuffet", "Mary Moffet" in that order on the ministers page

  Scenario: Administering the order of whips
    Given I am a GDS editor called "Jane"
    Given two whips "Wilma the Whip" and "Jake the Junior Whip"
    When I order the whips "Wilma the Whip", "Jake the Junior Whip"
    Then I should see "Wilma the Whip", "Jake the Junior Whip" in that order on the whips section of the ministers page
    When I order the whips "Jake the Junior Whip", "Wilma the Whip"
    Then I should see "Jake the Junior Whip", "Wilma the Whip" in that order on the whips section of the ministers page
