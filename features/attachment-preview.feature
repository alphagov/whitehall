Feature: Previewing CSV attachcments
  As a consumer of CSV data
  I want to be able to preview the content of CSV files
  So that I can get a sense of the contents without having to download the file

  Scenario: Previewing a CSV file attachment
    Given there is a publicly visible CSV attachment on the site
    When I preview the contents of the attachment
    Then I should see the CSV data previewed on the page
