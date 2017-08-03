Feature: Administering Organisations

Background:
  Given I am an admin in the organisation "Ministry of Pop"
  And a directory of organisations exists
  And a world location "United Kingdom" exists

Scenario: Adding an Organisation
  Given I have the "GDS Admin" permission
  When I add a new organisation called "Ministry of Jazz"
  Then I should be able to see "Ministry of Jazz" in the list of organisations

Scenario: Adding a sponsoring organisation
  Given I am an admin in the organisation "Administration for the Proliferation of Krunk"
  And the organisation "Association of Krunk" exists
  When I choose "Association of Krunk" as a sponsoring organisation of "Administration for the Proliferation of Krunk"
  Then I should see "Association of Krunk" listed as a sponsoring organisation of "Administration for the Proliferation of Krunk"

Scenario: Administering organisation contact details
  When I visit the organisation admin page for "Ministry of Pop"
  And I add a new contact "Main office" with address "1 Acacia Avenue"
  Then I should see the "Main office" contact in the admin interface with address "1 Acacia Avenue"
  When I edit the contact to have address "1 Acacia Road"
  Then I should see the "Main office" contact in the admin interface with address "1 Acacia Road"

Scenario: Featuring news on an organisation page
  And a published news article "You must buy the X-Factor single, says Queen" was produced by the "Ministry of Pop" organisation
  When I feature the news article "You must buy the X-Factor single, says Queen" for "Ministry of Pop" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured news articles in the "Ministry of Pop" organisation are:
    | You must buy the X-Factor single, says Queen | s630_minister-of-funk.960x640.jpg |
  When I stop featuring the news article "You must buy the X-Factor single, says Queen" for "Ministry of Pop"
  Then there should be nothing featured on the home page of "Ministry of Pop"

Scenario: Creating offsite content on an organisation page
  When I add the offsite link "Offsite Thing" of type "Alert" to the organisation "Ministry of Pop"
  Then I should see the edit offsite link "Offsite Thing" on the "Ministry of Pop" organisation page

Scenario: Featuring offsite content on an organisation page
  And I have an offsite link "Offsite Thing" for the organisation "Ministry of Pop"
  When I feature the offsite link "Offsite Thing" for organisation "Ministry of Pop" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured offsite links in the "Ministry of Pop" organisation are:
    | Offsite Thing | s630_minister-of-funk.960x640.jpg |
  When I stop featuring the offsite link "Offsite Thing" for "Ministry of Pop"
  Then there should be nothing featured on the home page of "Ministry of Pop"

@javascript
Scenario: Filtering items to feature on an organisation page
  Given an organisation and some documents exist
  When I go to the organisation feature page
  Then I can filter instantaneously the list of documents by title, author, organisation, and document type

Scenario: Featuring a topical event on an organisation page
  And the topical event "G8" exists
  When I feature the topical event "G8" for "Ministry of Pop" with image "minister-of-funk.960x640.jpg"
  Then I should see the featured topical events in the "Ministry of Pop" organisation are:
    | G8 | s630_minister-of-funk.960x640.jpg |
  When I stop featuring the topical event "G8" for "Ministry of Pop"
  Then there should be nothing featured on the home page of "Ministry of Pop"

Scenario: Defining the order of featured news on an organisation page
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
  And I set the alternative format contact email of "Ministry of Pop" to "alternative.format@ministry-of-pop.gov.uk"
  And a published publication "Charleston styles today" with a PDF attachment and alternative format provider "Ministry of Pop"
  Then the alternative format contact email is "alternative.format@ministry-of-pop.gov.uk"

Scenario: Adding featured links
  Given I am a GDS editor in the organisation "Ministry of Pop"
  When I add some featured links to the organisation "Ministry of Pop" via the admin
  Then the featured links for the organisation "Ministry of Pop" should be visible on the public site

Scenario: Adding featured services and guidance
  Given I am a GDS editor in the organisation "Ministry of Pop"
  When I add some featured services and guidance to the organisation "Ministry of Pop" via the admin
  Then the featured services and guidance for the organisation "Ministry of Pop" should be visible on the public site

Scenario: Managing social media links
  Given a social media service "Twooter"
  And a social media service "Facebark"
  When I add a "Twooter" social media link "http://twooter.com/beards-in-france" to the organisation
  And I add a "Facebark" social media link "http://facebark.com/beards-in-france" with the title "Beards on Facebark!" to the organisation
  Then the "Twooter" social link should be shown on the public website for the organisation
  And the "Facebark" social link called "Beards on Facebark!" should be shown on the public website for the organisation

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
  And I should see the high profile groups listed with count

Scenario: Viewing the organisations index and seeing the status of agencies and public bodies live on govuk
  Given 1 live, 1 transitioning and 1 exempt executive agencies
  When I visit the organisations page
  Then I should see metadata in the agency list indicating the status of each organisation which is not live

Scenario: Viewing the organisations index and seeing the status of non ministerial departments
  Given 1 live, 1 transitioning and 1 exempt non ministerial departments
  When I visit the organisations page
  Then I should see metadata in the non ministerial department list indicating the status of each organisation which is not live

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
  Given I am an editor in the organisation "Department of Fun"
  When I delete the organisation "Department of Fun"
  Then there should not be an organisation called "Department of Fun"

Scenario: DFID shows link to uk aid information
  Given the organisation "Department for International Development" exists
  And the organisation "Cabinet Office" exists
  Then I can see information about uk aid on the "Department for International Development" page
  And I can not see information about uk aid on the "Cabinet Office" page

Scenario: Admin closes an organisation, superseding it with another one
  Given I am an editor in the organisation "Department of wombat population control"
  And the organisation "Wimbledon council of wombat population control" exists
  When I close the organisation "Department of wombat population control", superseding it with the organisation "Wimbledon council of wombat population control"
  Then I can see that the organisation "Department of wombat population control" has been superseded with the organisaion "Wimbledon council of wombat population control"

Scenario: Citizen views a closed organisation
  Given a closed organisation with documents which has been superseded by another
  When I view the organisation
  Then I can see that the organisation is closed and has been superseded by the other
  And I can see the documents associated with that organisation

Scenario: Featuring policies on an organisation
  Given I am an editor in the organisation "Department of Fun"
  And and the policies "Dance around" and "Sing aloud" exist
  When I feature the policies "Dance around" and "Sing aloud" for "Department of Fun"
  Then I should see the featured policies in the "Department of Fun" organisation are:
    |Dance around|
    |Sing aloud|
  When I stop featuring the polices "Dance around" for "Department of Fun"
  Then I should see the featured policies in the "Department of Fun" organisation are:
    |Sing aloud|
  When I stop featuring the polices "Sing aloud" for "Department of Fun"
  Then there should be no featured policies on the home page of "Department of Fun"

Scenario: Setting the order of policies featured on an organisation
  Given I am an editor in the organisation "Department of Fun"
  And and the policies "Dance around" and "Sing aloud" exist
  When I feature the policies "Dance around" and "Sing aloud" for "Department of Fun"
  And I order the featured policies in the "Department of Fun" organisation as:
    |Sing aloud|
    |Dance around|
  Then I should see the featured policies in the "Department of Fun" organisation are:
    |Sing aloud|
    |Dance around|
