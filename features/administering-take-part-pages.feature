Feature: Administering take part pages
  As a GDS editor
  I want to be able to administer the featured items in the take part section
  So that I can ensure the public are informed about the most relevant opportunities to take part

  ~~

  Add a new 'take part page' which works like a corporate information page, without any workflow or audit trail.

  It has:

    title: string
    summary: text
    body: govspeak
    image: image

  They can be reordered so the /get-involved index lists them in a pleasing manner
  
  Background:
    Given I am a GDS editor
  
  Scenario: When creating a take part page and reordering the list, the /get-involved shows the new one and my ordering
    Given there are some take part pages for the get involved section
    When I create a new take part page called "Fund raising in Novembeard"
    And I reorder the take part pages to highlight my new page
    Then I see the take part pages in my specified order including the new page on the frontend get involved section
    And I can click through to read all about my new page

  @allow-rescue
  Scenario: I can remove a take part page and it no longer displays them on /get-involved
    Given there are some take part pages for the get involved section
    When I remove one of the take part pages because it's not something we want to promote
    Then the removed take part page is no longer displayed on the frontend get involved section
