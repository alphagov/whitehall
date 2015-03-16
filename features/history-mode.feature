Feature: history-mode
  As a member of the public
  I want to know when a document was published under a previous government
  So that I know it does not reflect the view of the current government

Scenario: reading a political document from a previous government
  Given there is a current government
  And there is a political document from a previous government
  Then it should be publicly marked as belonging to the previous government
