Feature: Administering Organisations

Background:
  Given I am an admin called "Jane"

Scenario: Adding an Organisation
  When I add a new organisation called "Ministry of Jazz"
  Then I should be able to see "Ministry of Jazz" in the list of organisations

Scenario: Adding a sponsoring organisation
  Given two organisations "Association of Krunk" and "Administration for the Proliferation of Krunk" exist
  When I choose "Association of Krunk" as a sponsoring organisation of "Administration for the Proliferation of Krunk"
  Then I should "Association of Krunk" listed as a sponsoring organisation of "Administration for the Proliferation of Krunk"

Scenario: Administering organisation contact details
  Given the organisation "Ministry of Pop" exists
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

@javascript
Scenario: Filtering items to feature on an organisation page
  Given an organisation and some documents exist
  When I go to the organisation feature page
  Then I can filter instantaneously the list of documents by title, author, organisation, and document type

Scenario: Featuring a topical event on an organisation page
  Given the organisation "Ministry of Pop" exists
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
  Given the organisation "Ministry of Pop" exists
  And I set the alternative format contact email of "Ministry of Pop" to "alternative.format@ministry-of-pop.gov.uk"
  And a published publication "Charleston styles today" with a PDF attachment and alternative format provider "Ministry of Pop"
  When I visit the publication "Charleston styles today"
  Then I should see a mailto link for the alternative format contact email "alternative.format@ministry-of-pop.gov.uk"

Scenario: Adding top tasks
  Given the organisation "Ministry of Pop" exists
  When I add some top tasks to the organisation "Ministry of Pop" via the admin
  Then the top tasks for the organisation "Ministry of Pop" should be visible on the public site

Scenario: Managing social media links
  Given the organisation "Ministry of Pop" exists
  And a social media service "Twooter"
  And a social media service "Facebark"
  When I add a "Twooter" social media link "http://twooter.com/beards-in-france" to the organisation
  And I add a "Facebark" social media link "http://facebark.com/beards-in-france" with the title "Beards on Facebark!" to the organisation
  Then the "Twooter" social link should be shown on the public website for the organisation
  And the "Facebark" social link called "Beards on Facebark!" should be shown on the public website for the organisation

Scenario: Managing mainstream categories
  Given I am an admin called "Jane"
  And there is an organisation with no mainstream categories defined
  Then the public page for the organisation says nothing about mainstream categories
  But the admin page for the organisation says it has no mainstream categories
  And there are some mainstream categories
  When I add a few of those mainstream categories in a specific order to the organisation
  Then only the mainstream categories I chose appear on the public page for the organisation, in my specified order
  And they also appear on the admin page, in my specified order

Scenario: Adding a new translation
  Given the organisation "Department of Beards" exists
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
  Given the organisation "Department of Beards" exists with a translation for the locale "Français"
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

Scenario: Viewing the organisations index and seeing organisations grouped into categories
  Given some organisations of every type exist
  When I visit the organisations page
  Then I should see the executive offices listed
  And I should see the ministerial departments including their sub-organisations listed with count and number live
  And I should see the non ministerial departments including their sub-organisations listed with count
  And I should see the agencies and government bodies listed with count
  And I should see the public corporations listed with count
  And I should see the devolved administrations listed with count

Scenario: Viewing the organisations index and seeing a visualisation of the number of agencies and public bodies live on govuk
  Given 1 live, 1 transitioning and 1 exempt executive agencies
  When I visit the organisations page
  Then I should see a transition visualisation showing 1 out of 2 agencies moved plus 1 agency
  And I should see metadata in the agency list indicating the status of each organisation which is not live

Scenario: Viewing the organisations index and seeing a visualisation of the number of non ministerial departments
  Given 1 live, 1 transitioning and 1 exempt non ministerial departments
  When I visit the organisations page
  Then I should see a transition visualisation showing 1 out of 2 non ministerial departments moved plus 1 not moving
  And I should see metadata in the non ministerial department list indicating the status of each organisation which is not live

Scenario: Organisation page should show policies
  Given the organisation "Attorney General's Office" contains some policies
  And other organisations also have policies
  When I visit the "Attorney General's Office" organisation
  Then I should only see published policies belonging to the "Attorney General's Office" organisation

Scenario: Organisation page should show consultations
  Given the organisation "Attorney General's Office" is associated with consultations "More tea vicar?" and "Cake or biscuit?"
  When I visit the "Attorney General's Office" organisation
  Then I can see links to the consultations "More tea vicar?" and "Cake or biscuit?"

Scenario: Organisation page should show the ministers
  Given the "Attorney General's Office" organisation is associated with several ministers and civil servants
  When I visit the "Attorney General's Office" organisation
  Then I should be able to view all civil servants for the "Attorney General's Office" organisation
  And I should be able to view all ministers for the "Attorney General's Office" organisation

Scenario: Organisation page should show any traffic commissioners
  Given the "Department for Transport" organisation is associated with traffic commissioners
  When I visit the "Department for Transport" organisation
  Then I should be able to view all traffic commissioners for the "Department for Transport" organisation

Scenario: Organisation page should show any chief professional officers
  Given the "Department of Health" organisation is associated with chief professional officers
  When I visit the "Department of Health" organisation
  Then I should be able to view all chief professional officers for the "Department of Health" organisation

Scenario: Organisation page should show any chief scientific advisors
  Given the "Department for Transport" organisation is associated with scientific advisors
  When I visit the "Department for Transport" organisation
  Then I should be able to view all civil servants for the "Department for Transport" organisation

Scenario: Organisation pages links to transparency data publications
  Given the organisation "Cabinet Office" exists
  Then I cannot see links to Transparency data on the "Cabinet Office" about page
  When I associate a Transparency data publication to the "Cabinet Office"
  Then I can see a link to "Transparency data" on the "Cabinet Office" about page

Scenario: Organisation page lists promotional features for executive offices
  Given the executive office organisation "Number 32 - The Cheese Office" exists
  And the executive office has a promotional feature with an item
  Then I should see the promotional feature on the executive office page

Scenario: deleting an organisation with no children or roles
  Given I am an editor
  And the organisation "Department of Fun" exists
  When I delete the organisation "Department of Fun"
  Then there should not be an organisation called "Department of Fun"

Scenario: DFID shows link to uk aid information
  Given the organisation "Department for International Development" exists
  And the organisation "Cabinet Office" exists
  Then I can see information about uk aid on the "Department for International Development" page
  And I can not see information about uk aid on the "Cabinet Office" page

Scenario: Admin closes an organisation, superseding it with another one
  Given the organisation "Department of wombat population control" exists
  And the organisation "Wimbledon council of wombat population control" exists
  When I close the organisation "Department of wombat population control", superseding it with the organisation "Wimbledon council of wombat population control"
  # Then I can see that the organisation "Department of wombat population control" has been superseded with the organisaion "Wimbledon council of wombat population control"



