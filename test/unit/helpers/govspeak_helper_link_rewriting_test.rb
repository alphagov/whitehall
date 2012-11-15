require 'test_helper'

class GovspeakHelperLinkRewritingTest < ActionView::TestCase
  include GovspeakHelper
  include Admin::EditionRoutesHelper
  include PublicDocumentRoutesHelper
  include Rails.application.routes.url_helpers

  setup do
    @request  = ActionController::TestRequest.new
    ActionController::Base.default_url_options = {}
  end
  attr_reader :request

  Whitehall.edition_classes.each do |edition_class|
    test "should rewrite absolute link to an admin page for a published #{edition_class} as link to its public page" do
      edition = create("published_#{edition_class.name.underscore}")
      assert_rewrites_link(from: admin_edition_url(edition), to: public_document_url(edition))
    end

    test "should rewrite relative link to an admin page for a published #{edition_class} as link to its public page" do
      edition = create("published_#{edition_class.name.underscore}")
      assert_rewrites_link(from: admin_edition_path(edition), to: public_document_url(edition))
    end
  end

  test "should rewrite absolute link to an admin page for a published supporting page as link to its public page" do
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    assert_rewrites_link(from: admin_supporting_page_url(supporting_page), to: public_supporting_page_url(policy, supporting_page))
  end

  test "should rewrite link without confusing supporting pages with the same title on different documents" do
    policy_1 = create(:policy)
    supporting_page_1 = create(:supporting_page, edition: policy_1, title: "supporting-page-title")
    policy_1.delete
    policy_2 = create(:published_policy)
    supporting_page_2 = create(:supporting_page, edition: policy_2, title: "supporting-page-title")
    assert_rewrites_link(from: admin_supporting_page_url(supporting_page_2), to: public_supporting_page_url(policy_2, supporting_page_2))
  end

  test "should rewrite link to an admin page for an organisation as a link to its public page" do
    organisation = create(:organisation)
    assert_rewrites_link(from: admin_organisation_url(organisation), to: organisation_url(organisation))
  end

  test "should rewrite link to an admin page for an organisation corporate information to its public page" do
    organisation = create(:organisation, name: "department-for-communities-and-local-government")
    page = create(:corporate_information_page, organisation: organisation)
    assert_rewrites_link(from: admin_organisation_corporate_information_page_url(organisation, page), to: organisation_corporate_information_page_url(organisation, page))
  end

  test "should rewrite link to an admin edit page for an organisation corporate information to its public page" do
    organisation = create(:organisation, name: "department-for-communities-and-local-government")
    page = create(:corporate_information_page, organisation: organisation)
    assert_rewrites_link(from: edit_admin_organisation_corporate_information_page_url(organisation, page), to: organisation_corporate_information_page_url(organisation, page))
  end

  test "should rewrite link to an admin page for an organisation document series to its public page" do
    organisation = create(:organisation, name: "department-for-communities-and-local-government")
    document_series = create(:document_series, organisation: organisation)
    assert_rewrites_link(from: admin_organisation_document_series_url(organisation, document_series), to: organisation_document_series_url(organisation, document_series))
  end

  test "should not raise exception when link to an admin edit page for an organisation document series is present" do
    organisation = create(:organisation, name: "department-for-communities-and-local-government")
    document_series = create(:document_series, organisation: organisation)
    assert_rewrites_link(from: edit_admin_organisation_document_series_url(organisation, document_series), to: organisation_document_series_url(organisation, document_series))
  end

  test 'should rewrite admin link to an archived edition as a link to its published edition' do
    archived_edition, published_edition = create_archived_policy_with_published_edition
    assert_rewrites_link(from: admin_edition_url(archived_edition), to: public_document_url(published_edition))
  end

  test 'should rewrite admin link to a draft edition as a link to its published edition' do
    published_edition, new_draft = create_draft_policy_with_published_edition
    assert_rewrites_link(from: admin_edition_url(new_draft), to: public_document_url(published_edition))
  end

  test "should rewrite absolute link to an admin page for a speech as a link to its public page on the internal preview host" do
    request.host = ActionController::Base.default_url_options[:host] = internal_preview_host
    speech = create(:published_speech)
    assert_rewrites_link(from: admin_speech_url(speech), to: public_document_url(speech))
  end

  test "should rewrite absolute link to an admin page for a speech as a link to its public page on the public preview host" do
    request.host = public_preview_host
    ActionController::Base.default_url_options[:host] = internal_preview_host
    speech = create(:published_speech)
    assert_rewrites_link(from: admin_speech_url(speech), to: public_document_url(speech))
  end

  test "should rewrite absolute link to an admin page for a supporting page as a link to its public page on the internal preview host" do
    request.host = ActionController::Base.default_url_options[:host] = internal_preview_host
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    assert_rewrites_link(from: admin_supporting_page_url(supporting_page), to: public_supporting_page_url(policy, supporting_page, host: public_preview_host))
  end

  test "should rewrite absolute link to an admin page for a supporting page as a link to its public page on the public preview host" do
    request.host = public_preview_host
    ActionController::Base.default_url_options[:host] = internal_preview_host
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    assert_rewrites_link(from: admin_supporting_page_url(supporting_page), to: public_supporting_page_url(policy, supporting_page, host: public_preview_host))
  end

  test "should rewrite absolute link to an admin page for a speech as a link to its public page on the internal production host" do
    request.host = ActionController::Base.default_url_options[:host] = internal_production_host
    speech = create(:published_speech)
    assert_rewrites_link(from: admin_speech_url(speech), to: public_document_url(speech))
  end

  test "should rewrite absolute link to an admin page for a speech as a link to its public page on the public production host" do
    request.host = public_production_host
    ActionController::Base.default_url_options[:host] = internal_production_host
    speech = create(:published_speech)
    assert_rewrites_link(from: admin_speech_url(speech), to: public_document_url(speech))
  end

  test "should rewrite absolute link to an admin page for a supporting page as a link to its public page on the internal production host" do
    request.host = ActionController::Base.default_url_options[:host] = internal_production_host
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    assert_rewrites_link(from: admin_supporting_page_url(supporting_page), to: public_supporting_page_url(policy, supporting_page, host: public_production_host))
  end

  test "should rewrite absolute link to an admin page for a supporting page as a link to its public page on the public production host" do
    request.host = public_production_host
    ActionController::Base.default_url_options[:host] = internal_production_host
    policy = create(:published_policy)
    supporting_page = create(:supporting_page, edition: policy)
    assert_rewrites_link(from: admin_supporting_page_url(supporting_page), to: public_supporting_page_url(policy, supporting_page, host: public_production_host))
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

  test "should not link to supporting pages whose editions are not published" do
    policy = create(:draft_policy)
    supporting_page = create(:supporting_page, edition: policy)
    url = admin_supporting_page_url(supporting_page)
    html = govspeak_to_html("this and [that](#{url}) yeah?")
    refute_select_within_html html, "a"
  end

  private

  def internal_preview_host
    "whitehall.preview.alphagov.co.uk"
  end

  def public_preview_host
    "www.preview.alphagov.co.uk"
  end

  def internal_production_host
    "whitehall.production.alphagov.co.uk"
  end

  def public_production_host
    "www.gov.uk"
  end

  def assert_rewrites_link(options = {})
    html = govspeak_to_html("this and [that](#{options[:from]}) yeah?")
    assert_select_within_html html, "a[href=?]", options[:to], text: "that"
  end

  def create_archived_policy_with_published_edition
    edition = create(:published_policy)
    writer = create(:policy_writer)
    editor = create(:departmental_editor)
    new_draft = edition.create_draft(writer)
    new_draft.change_note = 'change-note'
    new_draft.save_as(writer)
    new_draft.submit!
    new_draft.publish_as(editor)
    [edition, new_draft]
  end

  def create_draft_policy_with_published_edition
    edition = create(:published_policy)
    writer = create(:policy_writer)
    new_draft = edition.create_draft(writer)
    new_draft.change_note = 'change-note'
    new_draft.save_as(writer)
    [edition, new_draft]
  end
end
