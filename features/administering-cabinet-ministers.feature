Feature:
  As the No 10/Cabinet Office digital team
  We want curate the order in which ministers are listed in the Cabinet section of the ministers page
  So that the seniority of members of cabinet is accurately reflected

Scenario: Administering the order of cabinet ministers
  Given I am a GDS editor called "Jane"
  Given two cabinet ministers "Mary Moffet" and "Catherine Tuffet"
  When I order the cabinet ministers "Mary Moffet", "Catherine Tuffet"
  Then I should see "Mary Moffet", "Catherine Tuffet" in that order on the ministers page
  When I order the cabinet ministers "Catherine Tuffet", "Mary Moffet"
  Then I should see "Catherine Tuffet", "Mary Moffet" in that order on the ministers page
