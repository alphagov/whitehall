Feature: Bulk republishing content
  As an editor
  I want to be able to republish content in bulk
  So that they reflect changes to their dependencies when this doesn't happen automatically

  Background:
    Given I am a GDS admin

  Scenario: Republish all documents
    Given Documents exist
    When I request a bulk republishing of all documents
    Then I can see that all documents have been queued for republishing

  Scenario: Republish all Organisation "About Us" pages
    Given Published Organisation "About Us" pages exist
    When I request a bulk republishing of the Organisation "About Us" pages
    Then I can see the Organisation "About Us" pages have been queued for republishing
