require "test_helper"

class Admin::AdminGovspeakHelperTest < ActionView::TestCase
  include Admin::EditionRoutesHelper

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
    assert_select_within_html html, "a[href=?]", publication.public_url, text: "☃"
  end

  test "should rewrite link to deleted edition in admin preview" do
    publication = create(:deleted_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "del", text: "that"
  end

  test "should rewrite link to missing edition in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path('98765')})")
    assert_select_within_html html, "del", text: "that"
  end

  test "should rewrite link to bad edition ID in admin preview" do
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path('not-an-id')})")
    assert_select_within_html html, "del", text: "that"
  end

  test "should rewrite link to published edition in admin preview" do
    publication = create(:published_publication)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", publication.public_url, text: "that"
  end

  test "should rewrite link to published edition with a newer draft in admin preview" do
    publication = create(:published_publication)
    new_draft = publication.create_draft(create(:writer))
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", admin_publication_path(new_draft), text: "draft"
  end

  test "should rewrite link to superseded edition with a newer published edition in admin preview" do
    publication = create(:published_publication)
    writer = create(:writer)
    new_edition = publication.create_draft(writer)
    new_edition.change_note = "change-note"
    new_edition.save_as(writer)
    new_edition.submit!
    publish(new_edition)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(publication)})")
    assert_select_within_html html, "a[href=?]", admin_publication_path(new_edition), text: "published"
  end

  test "should rewrite link to deleted edition with an older published edition in admin preview" do
    document = create(:document)
    publication = create(:published_publication, document:)
    deleted_edition = create(:deleted_publication, document:)
    html = govspeak_to_admin_html("this and [that](#{admin_publication_path(deleted_edition)})")
    assert_select_within_html html, "a[href=?]", admin_publication_path(publication), text: "published"
  end

  test "should allow attached images to be embedded in admin html" do
    image = build(:image)
    html = govspeak_to_admin_html("!!1", [image])
    assert_select_within_html html, ".govspeak figure.image.embedded img[src=?]", image.url
  end

  test "should allow attached images to be embedded in edition body" do
    image = build(:image)
    edition = build(:published_news_article, body: "!!1", images: [image])
    html = govspeak_edition_to_admin_html(edition)
    assert_select_within_html html, ".govspeak figure.image.embedded img[src=?]", image.url
  end

  test "uses the frontend contacts/_contact partial when rendering embedded contacts, not the admin partial" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    output = govspeak_to_admin_html(input)
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", output
  end

  test "use the frontend html version of the contact partial, even if the view context is for a different format" do
    contact = build(:contact)
    Contact.stubs(:find_by).with(id: "1").returns(contact)
    input = "[Contact:1]"
    contact_html = render("contacts/contact", contact:, heading_tag: "p")
    @controller.lookup_context.formats = %i[atom]
    assert_nothing_raised do
      assert_equivalent_html "<div class=\"govspeak\">#{contact_html}</div>", govspeak_to_admin_html(input)
    end
  end
end
