# encoding: UTF-8
require 'test_helper'

class Admin::AdminGovspeakHelperTest < ActionView::TestCase
  include Admin::EditionRoutesHelper
  include PublicDocumentRoutesHelper

  setup do
    @request  = ActionController::TestRequest.new
    ActionController::Base.default_url_options = {}
    # To mimic the setup for this helper where it is likely to be used
    # e.g. in Admin:: prefixed controllers and admin/ views
    @controller.lookup_context.prefixes = ['admin/base']
  end
  attr_reader :request

  test "should wrap admin output with a govspeak class" do
    html = govspeak_to_admin_html("govspeak-text")
    assert_select_within_html html, ".govspeak", text: "govspeak-text"
  end

  test "should mark the admin govspeak output as html safe" do
    html = govspeak_to_admin_html("govspeak-text")
    assert html.html_safe?
  end

  test "should not alter mailto urls in the admin preview" do
    html = govspeak_to_admin_html("no [change](mailto:dave@example.com)")
    assert_select_within_html html, "a[href=?]", "mailto:dave@example.com", text: "change"
  end

  test "should not alter urls to other sites in the admin preview" do
    html = govspeak_to_admin_html("no [change](http://external.example.com/page.html)")
    assert_select_within_html html, "a[href=?]", "http://external.example.com/page.html", text: "change"
  end

  test "should not alter partial urls in the admin preview" do
    html = govspeak_to_admin_html("no [change](http://)")
    assert_select_within_html html, "a[href=?]", "http://", text: "change"
  end

  test "should rewrite link to draft edition in admin preview" do
    publication = create(:draft_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", admin_publication_path(publication), text: "draft"
  end

  test "should not alter unicode when replacing links" do
    publication = create(:published_publication)
    html = govspeak_to_admin_html("the [☃](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", public_document_url(publication), text: "☃"
  end

  test "should rewrite link to deleted edition in admin preview" do
    publication = create(:draft_publication)
    publication.delete!
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "del", text: "that"
  end

  test "should rewrite link to missing edition in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path('missing-id')})")
    assert_select_within_html html, "del", text: "that"
  end

  test "should rewrite link to destroyed supporting page in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_supporting_page_path("doesnt-exist", "missing-id")})")
    assert_select_within_html html, "del", text: "that"
  end

  test "should rewrite link to published edition in admin preview" do
    publication = create(:published_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", public_document_url(publication), text: "that"
  end

  test "should rewrite link to published edition with a newer draft in admin preview" do
    publication = create(:published_publication)
    new_draft = publication.create_draft(create(:policy_writer))
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", admin_publication_path(new_draft), text: "draft"
  end

  test "should rewrite link to superseded edition with a newer published edition in admin preview" do
    publication = create(:published_publication)
    writer = create(:policy_writer)
    new_edition = publication.create_draft(writer)
    new_edition.change_note = "change-note"
    new_edition.save_as(writer)
    new_edition.submit!
    publish(new_edition)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", admin_publication_path(new_edition), text: "published"
  end

  test "should rewrite link to deleted edition with an older published edition in admin preview" do
    publication = create(:published_publication)
    new_draft = publication.create_draft(create(:policy_writer))
    new_draft.delete!
    deleted_edition = new_draft
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(deleted_edition)})")
    assert_select_within_html html, "a[href=?]", admin_publication_path(publication), text: "published"
  end

  test "should allow attached images to be embedded in admin html" do
    images = [OpenStruct.new(alt_text: "My Alt", url: "/image.jpg")]
    html = govspeak_to_admin_html("!!1", images)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src=" + Whitehall.asset_host + "/image.jpg]"
  end

  test "prefixes embedded image urls with asset host if present" do
    Whitehall.stubs(:asset_host).returns("https://some.cdn.com")
    edition = build(:published_news_article, body: "!!1")
    edition.stubs(:images).returns([OpenStruct.new(alt_text: "My Alt", url: "/image.jpg")])
    html = govspeak_edition_to_admin_html(edition)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src=https://some.cdn.com/image.jpg]"
  end

  test 'uses the frontend contacts/_contact partial when rendering embedded contacts, not the admin partial' do
    contact = build(:contact)
    Contact.stubs(:find_by_id).with('1').returns(contact)
    input = '[Contact:1]'
    output = govspeak_to_admin_html(input)
    contact_html = render('contacts/contact', contact: contact, heading_tag: 'h3')
    assert_equal "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  test 'use the frontend html version of the contact partial, even if the view context is for a different format' do
    contact = build(:contact)
    Contact.stubs(:find_by_id).with('1').returns(contact)
    input = '[Contact:1]'
    contact_html = render('contacts/contact', contact: contact, heading_tag: 'h3')
    @controller.lookup_context.formats = ['atom']
    assert_nothing_raised(ActionView::MissingTemplate) do
      assert_equal "<div class=\"govspeak\">#{contact_html}</div>", govspeak_to_admin_html(input)
    end
  end

end
