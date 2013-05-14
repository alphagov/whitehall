Feature: Administering Organisations

Scenario: Administering organisation contact details
  Given I am an admin called "Jane"
  And the organisation "Ministry of Pop" exists
  When I visit the organisation admin page for "Ministry of Pop"
  And I add a new contact "Main office" with address "1 Acacia Avenue"
  Then I should see the "Main office" contact in the admin interface with address "1 Acacia Avenue"
  When I edit the contact to have address "1 Acacia Road"
  Then I should see the "Main office" contact in the admin interface with address "1 Acacia Road"

Scenario: Featuring news on an organisation page
  Given the organisation "Ministry of Pop" exists
  And a published news article "You must buy the X-Factor single, says Queen" was produced by the "Ministry of Pop" organisation
  When I feature the news article "You must buy the X-Factor single, says Queen" for "Ministry of Pop" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured news articles in the "Ministry of Pop" organisation are:
    | You must buy the X-Factor single, says Queen | s630_minister-of-funk.960x640.jpg |
  When I stop featuring the news article "You must buy the X-Factor single, says Queen" for "Ministry of Pop"
  Then there should be nothing featured on the home page of "Ministry of Pop"

Scenario: Featuring a topical event on an organisation page
  Given I am an admin called "Jane"
  And the organisation "Ministry of Pop" exists
  And the topical event "G8" exists
  When I feature the topical event "G8" for "Ministry of Pop" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured topical events in the "Ministry of Pop" organisation are:
    | G8 | s630_minister-of-funk.960x640.jpg |
  When I stop featuring the topical event "G8" for "Ministry of Pop"
  Then there should be nothing featured on the home page of "Ministry of Pop"

Scenario: Defining the order of featured news on an organisation page
  Given the organisation "Ministry of Pop" exists
  And a published news article "You must buy the X-Factor single, says Queen" was produced by the "Ministry of Pop" organisation
  And a published news article "Bringing back the Charleston" was produced by the "Ministry of Pop" organisation
  And I feature the news article "Bringing back the Charleston" for "Ministry of Pop"
  And I feature the news article "You must buy the X-Factor single, says Queen" for "Ministry of Pop"
  When I order the featured items in the "Ministry of Pop" organisation as:
    |You must buy the X-Factor single, says Queen|
    |Bringing back the Charleston|
  Then I should see the featured news articles in the "Ministry of Pop" organisation are:
    |You must buy the X-Factor single, says Queen|
    |Bringing back the Charleston|

Scenario: Requesting publications in alternative format
  Given I am an admin called "Jane"
  And the organisation "Ministry of Pop" exists
  And I set the alternative format contact email of "Ministry of Pop" to "alternative.format@ministry-of-pop.gov.uk"
  And a published publication "Charleston styles today" with a PDF attachment and alternative format provider "Ministry of Pop"
  When I visit the publication "Charleston styles today"
  Then I should see a mailto link for the alternative format contact email "alternative.format@ministry-of-pop.gov.uk"

Scenario: Adding mainstream services
  Given I am an admin called "Jane"
  And the organisation "Ministry of Pop" exists
  When I add some mainstream links to "Ministry of Pop" via the admin
  Then the mainstream links for "Ministry of Pop" should be visible on the public site

Scenario: Managing social media links
  Given I am an admin called "Jane"
  And the organisation "Ministry of Pop" exists
  And a social media service "Twooter"
  And a social media service "Facebark"
  When I add a "Twooter" social media link "http://twooter.com/beards-in-france" to the organisation
  And I add a "Facebark" social media link "http://facebark.com/beards-in-france" with the title "Beards on Facebark!" to the organisation
  Then the "Twooter" social link should be shown on the public website for the organisation
  And the "Facebark" social link called "Beards on Facebark!" should be shown on the public website for the organisation

Scenario: Managing mainstream categories
  Given I am an admin called "Jane"
  And there is an organisation with no mainstream cateegories defined
  Then the public website for the organisation says nothing about mainstream categories
  And there are some mainstream categories
  When I add a few of those mainstream categories in a specific order to the organisation
  Then only the mainstream categories I chose appear on the public website for the organisation, in my specified order

Scenario: Adding a new translation
  Given I am an admin called "Jane"
  And the organisation "Department of Beards" exists
  When I add a new translation to the organisation with:
    | locale              | Français                                          |
    | name                | Département des barbes en France                  |
    | acronym             | DOF                                               |
    | logo formatted name | Département des barbes en France                  |
    | description         | Barbes, moustaches, même rouflaquettes            |
    | about us            | Nous nous occupons de la pilosité faciale du pays |
  Then when I view the organisation with the locale "Français" I should see:
    | name                | Département des barbes en France                  |
    | acronym             | DOF                                               |
    | logo formatted name | Département des barbes en France                  |
    | description         | Barbes, moustaches, même rouflaquettes            |
    | about us            | Nous nous occupons de la pilosité faciale du pays |

Scenario: Editing an existing translation
  Given I am an admin called "Jane"
  And the organisation "Department of Beards" exists with a translation for the locale "Français"
  When I edit the translation for the organisation setting:
    | locale              | Français                                          |
    | name                | Département des barbes en France                  |
    | acronym             | DOF                                               |
    | logo formatted name | Département des barbes en France                  |
    | description         | Barbes, moustaches, même rouflaquettes            |
    | about us            | Nous nous occupons de la pilosité faciale du pays |
  Then when I view the organisation with the locale "Français" I should see:
    | name                | Département des barbes en France                  |
    | acronym             | DOF                                               |
    | logo formatted name | Département des barbes en France                  |
    | description         | Barbes, moustaches, même rouflaquettes            |
    | about us            | Nous nous occupons de la pilosité faciale du pays |
