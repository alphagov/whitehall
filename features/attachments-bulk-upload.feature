Feature: bulk uploading attachments
  As a writer
  I want to be able to upload many attachments in one go
  In order to ease the burden of releasing documents with large amounts of data

  Specifically, within the context of an existing edition:
    - I can sidestep the existing attachments UI to upload a zip file of all my attachments
    - if the name of a file in my zip is the same as the name of an existing attachment, the newly uploaded file should replace the existing one, retaining all it's metadata (title, isbn, &c)
    - if the name of a file in my zip is not the same as an existing attachment I am prompted to fill in the metadata (title, isbn, &c)

  Scenario: Uploading a zip file to an existing document
    Given I am an editor
    And a draft publication "Legalise beards" with a PDF attachment
    When I upload a zip file with a new attachment and a replacement attachment to the publication "Legalise beards"
    Then I should see that I'm replacing the existing attachment, and adding a new one
    When I complete my edits by filling in the metadata for the new attachment
    And the attachments have been virus-checked
    And I preview the publication "Legalise beards"
    Then I should not see a link to the replaced attachment
    But I should see a link to the new attachment
    And I should see a link to the replacement attachment
    And the replaced data file should redirect to the replacement data file

  Scenario: Uploading a zip file to a new document
    Given I am an editor
    When I begin drafting a new publication "Ban beards"
    And I upload a zip file of new attachments to my new document
    Then I should see that I'm adding two new attachments
    When I complete my draft by filling in the metadata for the new attachments
    And the attachments have been virus-checked
    And I preview the publication "Ban beards"
    Then I should see links to the new attachments

