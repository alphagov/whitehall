Feature: Topical events
  Scenario Outline: Adding a social media account to an editionable topical event
    Given a social media service "Facebook" exists
    Given a topical event called "Test editionable topical event" with summary "A topical event" and description "A topical event"
    And I edit the editionable topical event "Test editionable topical event" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    Then I should see the "Our Facebook page" social media site has been assigned to the editionable topical event "Test editionable topical event"

  Scenario Outline: Editing a social media account to an editionable topical event
    Given a social media service "Facebook" exists
    Given a topical event called "Test editionable topical event" with summary "A topical event" and description "A topical event"
    And I edit the editionable topical event "Test editionable topical event" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    And I edit the editionable topical event "Test editionable topical event" changing the social media account with title "Our Facebook page" to "Our new Facebook page"
    Then I should see the "Our new Facebook page" social media site has been assigned to the editionable topical event "Test editionable topical event"

  Scenario Outline: Deleting a social media account assigned to an editionable topical event
    Given a social media service "Facebook" exists
    Given a topical event called "Test editionable topical event" with summary "A topical event" and description "A topical event"
    And I edit the editionable topical event "Test editionable topical event" adding the social media service of "Facebook" with title "Our Facebook page" at URL "https://www.social.gov.uk"
    And I edit the editionable topical event "Test editionable topical event" deleting the social media account with title "Our Facebook page"
    Then I should see the editionable topical event "Test editionable topical event" has no social media accounts