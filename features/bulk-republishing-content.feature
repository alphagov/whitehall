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

  Scenario: Republish all documents with pre-publication editions with HTML attachments
    Given Documents with pre-publication editions with HTML attachments exist
    When I request a bulk republishing of all documents with pre-publication editions with HTML attachments
    Then I can see that all documents with pre-publication editions with HTML attachments have been queued for republishing

  Scenario: Republish all documents with publicly-visible editions with attachments
    Given Documents with publicly-visible editions with attachments exist
    When I request a bulk republishing of all documents with publicly-visible editions with attachments
    Then I can see that all documents with publicly-visible editions with attachments have been queued for republishing

  Scenario: Republish all documents with publicly-visible editions with HTML attachments
    Given Documents with publicly-visible editions with HTML attachments exist
    When I request a bulk republishing of all documents with publicly-visible editions with HTML attachments
    Then I can see that all documents with publicly-visible editions with HTML attachments have been queued for republishing

  Scenario: Republish all published Organisation "About us" pages
    Given Published organisation "About us" pages exist
    When I request a bulk republishing of all published organisation "About us" pages
    Then I can see all published organisation "About us" pages have been queued for republishing

  Scenario: Republish non-editionable content types
    Given Contacts exist
    When I select all of type "Contact" for republishing
    Then I can see all of type "Contact" have been queued for republishing

  Scenario: Republish editionable content types
    Given Case Studies exist
    When I select all of type "CaseStudy" for republishing
    Then I can see all of type "CaseStudy" have been queued for republishing

  Scenario: Republish all documents by organisation
    Given a published organisation "An Existing Organisation" exists
    When I request a bulk republishing of all documents associated with "An Existing Organisation"
    Then I can see all documents associated with "An Existing Organisation" have been queued for republishing
