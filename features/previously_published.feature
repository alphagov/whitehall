Feature: Previously published options

Scenario: Creating a new case study without selecting a 'previously published' option
  Given I am a writer in the organisation "Department of Examples"
  When I start a new case study
  And I click save
  Then I see a validation error for the 'previously published' option

@javascript
Scenario: Creating a new case study and selecting a previously published date in the future
  Given the date is 2018-06-07
  And I am a writer in the organisation "Department of Examples"
  When I start a new case study
  And I select a previously published date in the future
  And I click save
  Then I see a validation error for the future date

Scenario: Creating a new case study and selecting previously published with no publication date
  Given the date is 2018-06-07
  And I am a writer in the organisation "Department of Examples"
  When I start a new case study
  And I select that this document has been previously published
  And I click save
  Then I see a validation error for the missing publication date

@javascript
Scenario: Creating a new case study with a valid previously published date
  Given the date is 2018-06-07
  And I am a writer in the organisation "Department of Examples"
  When I start a new case study
  And I select a previously published date in the past
  And I click save
  Then I should not see a validation error on the previously published date
