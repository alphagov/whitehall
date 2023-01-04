require "test_helper"

module Govspeak
  class AdminLinkReplacerTest < ActiveSupport::TestCase
    test "rewrites admin links for published editions" do
      speech     = create(:published_speech)
      public_url = speech.public_url
      fragment   = govspeak_to_nokogiri_fragment("this and [that](/government/admin/speeches/#{speech.id}) yeah?")

      AdminLinkReplacer.new(fragment).replace!

      assert_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "that"
    end

    test "unpublished edition links are replaced with plain text" do
      draft_speech = create(:draft_speech)
      _admin_path  = Whitehall.url_maker.admin_speech_path(draft_speech)
      fragment     = govspeak_to_nokogiri_fragment("this is an [unpublished thing](/government/admin/speeches/#{draft_speech.id})")

      AdminLinkReplacer.new(fragment).replace!

      refute_select_within_html fragment.to_html, "a"
      assert_select_within_html fragment.to_html, "p", text: "this is an unpublished thing"
    end

    test "rewrites admin links to published corporate information pages" do
      cip        = create(:published_corporate_information_page)
      admin_path = Whitehall.url_maker.polymorphic_path([:admin, cip.organisation, cip])
      public_url = cip.public_url
      fragment   = govspeak_to_nokogiri_fragment("Here is a link to an [info page](#{admin_path})")

      AdminLinkReplacer.new(fragment).replace!

      assert_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "info page"
    end

    test "handles cips on world orgs" do
      world_org  = create(:worldwide_organisation)
      cip        = create(:published_corporate_information_page, organisation: nil, worldwide_organisation: world_org)
      admin_path = Whitehall.url_maker.polymorphic_path([:admin, world_org, cip])
      public_url = cip.public_url
      fragment   = govspeak_to_nokogiri_fragment("Here is a link to a [world info page](#{admin_path})")

      AdminLinkReplacer.new(fragment).replace!

      assert_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "world info page"
    end

  private

    def govspeak_to_nokogiri_fragment(govspeak)
      doc = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"
      doc.fragment(Govspeak::Document.new(govspeak).to_html)
    end
  end
end
