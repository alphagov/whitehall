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

  Scenario: Republish all documents with pre-publication editions
    Given Documents with pre-publication editions exist
    When I request a bulk republishing of all documents with pre-publication editions
    Then I can see that all documents with pre-publication editions have been queued for republishing

  Scenario: Republish all published Organisation "About us" pages
    Given Published organisation "About us" pages exist
    When I request a bulk republishing of all published organisation "About us" pages
    Then I can see all published organisation "About us" pages have been queued for republishing
