Feature: HTML version of publications and consultations
  As a writer
  I want the option of adding markdown to a publication edition on
  Inside Gov which, when a citizen views it, displays as a separate "HTML"
  version of the publication (alongside PDF/etc versions)
  So we can provide information to citizens in a more convenient digital form
  than just PDFs and file attachments.

  - The user experience will be seeing the HTML format presented as one of a
  possible many formats alongside all the metadata, document collection info etc on
  the publication record page. It will feel like a separate entity, a bit like
  this: http://publications.cabinetoffice.gov.uk/digital/strategy/
  - it should be possible to add markdown directly to two new fields
  (html version title, html version body) on a publication edition which
  corresponds to the HTML version of that publication.
  - on the front end, it displays similarly to a PDF attachment with a
  label of HTML instead of the usual "PDF, n KB, n pages"
  - the html version of the publication outputs to a page which does
  not share any of our existing CSS. Don't worry about too much styling
  for now, although the producing org logo should be displayed on the
  html publication and a link back to the publication record page is
  displayed on the html publication.

  Background:
    Given I am an editor

  Scenario Outline: Adding an HTML version
    When I publish a <type> with an HTML version
    Then the HTML version of the <type> should be visible on the public page
    And citizens should be able to view the HTML version
    And the HTML version should be styled with the organisation logo
    And the HTML version should link back to the <type> record page

    Examples:
      | type         |
      | publication  |
      | consultation |

  Scenario: Adding an image to the HTML version of a publication
    When I begin drafting a new publication with an HTML version
    And I select an image for the publication
    And I reference the image from the HTML version
    Then the HTML version of the published publication should show the referenced image
