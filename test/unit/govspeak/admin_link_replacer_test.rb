require 'test_helper'

module Govspeak
  class AdminLinkReplacerTest < ActiveSupport::TestCase
    test 'rewrites admin links for published editions' do
      speech     = create(:published_speech)
      public_url = Whitehall.url_maker.public_document_url(speech)
      fragment   = govspeak_to_nokogiri_fragment("this and [that](/government/admin/speeches/#{speech.id}) yeah?")

      AdminLinkReplacer.new(fragment).replace!

      assert_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "that"
    end

    test "handles old style admin links for supporting pages" do
      policy          = create(:published_policy)
      supporting_page = create(:published_supporting_page, related_policies: [policy])
      EditionedSupportingPageMapping.create(old_supporting_page_id: 654321, new_supporting_page_id: supporting_page.id)
      admin_path      = "/government/admin/editions/#{policy.id}/supporting-pages/654321"
      public_url      = Whitehall.url_maker.policy_supporting_page_url(policy.document, supporting_page.document)
      fragment        = govspeak_to_nokogiri_fragment("this and [that](#{admin_path}) yeah?")

      AdminLinkReplacer.new(fragment).replace!

      assert_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "that"
    end

    test 'unpublished edition links are replaced with plain text' do
      draft_speech = create(:draft_speech)
      admin_path   = Whitehall.url_maker.admin_speech_path(draft_speech)
      public_url   = Whitehall.url_maker.public_document_url(draft_speech)
      fragment     = govspeak_to_nokogiri_fragment("this is an [unpublished thing](/government/admin/speeches/#{draft_speech.id})")

      AdminLinkReplacer.new(fragment).replace!

      refute_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "unpublished thing"
      assert_select_within_html fragment.to_html, "p", text: 'this is an unpublished thing'
    end

    test 'rewrites admin links to published corporate information pages' do
      cip = create(:published_corporate_information_page)
      admin_path = Whitehall.url_maker.polymorphic_path([:admin, cip.organisation, cip])
      public_url = Whitehall.url_maker.public_document_url(cip)
      fragment = govspeak_to_nokogiri_fragment("Here is a link to an [info page](#{admin_path})")

      AdminLinkReplacer.new(fragment).replace!

      assert_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "info page"
    end

    test 'handles cips on world orgs' do
      world_org  = create(:worldwide_organisation)
      cip        = create(:published_corporate_information_page, organisation: nil, worldwide_organisation: world_org)
      admin_path = Whitehall.url_maker.polymorphic_path([:admin, world_org, cip])
      public_url = Whitehall.url_maker.public_document_url(cip)
      fragment   = govspeak_to_nokogiri_fragment("Here is a link to a [world info page](#{admin_path})")

      AdminLinkReplacer.new(fragment).replace!

      assert_select_within_html fragment.to_html, "a[href='#{public_url}']", text: "world info page"
    end

    test 'replaces other types of admin links with plain text' do
      topic = create(:topic)
      fragment = govspeak_to_nokogiri_fragment("Here is an [admin link that should not link](/government/admin/topics/#{topic.id})")

      AdminLinkReplacer.new(fragment).replace!

      refute_select_within_html fragment.to_html, "a"
      assert_select_within_html fragment.to_html, "p", text: "Here is an admin link that should not link"
    end

  private

    def govspeak_to_nokogiri_fragment(govspeak)
      doc        = Nokogiri::HTML::Document.new
      doc.encoding = "UTF-8"
      doc.fragment(Govspeak::Document.new(govspeak).to_html)
    end
  end
end
