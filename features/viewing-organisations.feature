Feature: Viewing organisations

Scenario: Visiting a organisation page
  Given the organisation "Department of Paperclips" contains some policies
  And other organisations also have policies
  And ministers "Colonel Mustard" and "Professor Plum" are in the "Department of Paperclips"
  When I visit the "Department of Paperclips" organisation
  Then I should only see published policies belonging to the "Department of Paperclips" organisation
  And I should see ministers "Colonel Mustard" and "Professor Plum"