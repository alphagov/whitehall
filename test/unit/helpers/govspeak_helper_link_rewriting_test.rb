require 'test_helper'

class GovspeakHelperLinkRewritingTest < ActionView::TestCase
  include GovspeakHelper
  include Admin::EditionRoutesHelper
  include PublicDocumentRoutesHelper

  Whitehall.edition_classes.each do |edition_class|
    test "should rewrite absolute path to an admin page for a published #{edition_class} as link to its public page" do
      edition = create("published_#{edition_class.name.underscore}")
      assert_rewrites_link(from: admin_edition_path(edition), to: public_document_url(edition))
    end
  end

  test "should not raise exception when link to an admin page for an organisation is present" do
    organisation = create(:organisation)
    path = admin_organisation_url(organisation)
    assert_nothing_raised do
      govspeak_to_html("[text](#{path})")
    end
  end

  test "should not raise exception when link to an admin page for an organisation corporate information is present" do
    organisation = create(:organisation, name: "department-for-communities-and-local-government")
    page = create(:corporate_information_page, organisation: organisation)
    path = admin_organisation_corporate_information_page_path(organisation, page)
    assert_nothing_raised do
      govspeak_to_html("[text](#{path})")
    end
  end

  test "should not raise exception when link to an admin edit page for an organisation corporate information is present" do
    organisation = create(:organisation, name: "department-for-communities-and-local-government")
    page = create(:corporate_information_page, organisation: organisation)
    path = edit_admin_organisation_corporate_information_page_path(organisation, page)
    assert_nothing_raised do
      govspeak_to_html("[text](#{path})")
    end
  end

  test "should not raise exception when link to an admin page for an organisation document collection is present" do
    document_collection = create(:document_collection)
    path = admin_document_collection_path(document_collection)
    assert_nothing_raised do
      govspeak_to_html("[text](#{path})")
    end
  end

  test "should not raise exception when link to an admin edit page for an organisation document collection is present" do
    document_collection = create(:document_collection)
    path = edit_admin_document_collection_path(document_collection)
    assert_nothing_raised do
      govspeak_to_html("[text](#{path})")
    end
  end

  test 'should rewrite admin link to an superseded edition as a link to its published edition' do
    superseded_edition, published_edition = create_superseded_document_with_published_edition
    assert_rewrites_link(from: admin_edition_path(superseded_edition), to: public_document_url(published_edition))
  end

  test 'should rewrite admin link to a draft edition as a link to its published edition' do
    published_edition, new_draft = create_draft_document_with_published_edition
    assert_rewrites_link(from: admin_edition_path(new_draft), to: public_document_url(published_edition))
  end

  test "should rewrite absolute path to an admin page for a speech as a link to its public page" do
    speech = create(:published_speech)
    assert_rewrites_link(from: admin_speech_path(speech), to: public_document_url(speech))
  end

  test "should not link to draft editions with no published edition" do
    publication = create(:draft_publication)
    url = admin_publication_url(publication)
    html = govspeak_to_html("this and [that](#{url})")
    refute_select_within_html html, "a"
  end

  test "should not link to deleted editions with no published edition" do
    publication = create(:deleted_publication)
    url = admin_publication_url(publication)
    html = govspeak_to_html("this and [that](#{url})")
    refute_select_within_html html, "a"
  end

private

  def assert_rewrites_link(options = {})
    html = govspeak_to_html("this and [that](#{options[:from]}) yeah?")
    assert_select_within_html html, "a[href=?]", options[:to], { text: "that" }, html
  end

  def create_superseded_document_with_published_edition
    edition = create(:published_publication)
    writer = create(:writer)
    new_draft = edition.create_draft(writer)
    new_draft.change_note = 'change-note'
    new_draft.save_as(writer)
    new_draft.submit!
    publish(new_draft)
    [edition, new_draft]
  end

  def create_draft_document_with_published_edition
    edition = create(:published_publication)
    writer = create(:writer)
    new_draft = edition.create_draft(writer)
    new_draft.change_note = 'change-note'
    new_draft.save_as(writer)
    [edition, new_draft]
  end
end
