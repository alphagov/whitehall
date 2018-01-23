require 'test_helper'

module Whitehall
  class AdminLinkLookupTest < ActiveSupport::TestCase
    test "finds published edition" do
      speech = create(:published_speech)

      edition = AdminLinkLookup.find_edition("/government/admin/speeches/#{speech.id}")

      assert_equal(speech, edition)
    end

    test "finds corporate information page" do
      cip = create(:published_corporate_information_page)
      admin_path = Whitehall.url_maker.polymorphic_path([:admin, cip.organisation, cip])

      edition = AdminLinkLookup.find_edition(admin_path)

      assert_equal(cip, edition)
    end

    test "finds worldwide corporate information page" do
      world_org = create(:worldwide_organisation)
      cip = create(:published_corporate_information_page, organisation: nil, worldwide_organisation: world_org)
      admin_path = Whitehall.url_maker.polymorphic_path([:admin, world_org, cip])

      edition = AdminLinkLookup.find_edition(admin_path)

      assert_equal(cip, edition)
    end

    test "finds edition from full URL" do
      speech = create(:published_speech)

      edition = AdminLinkLookup.find_edition("https://whitehall-admin.publishing.service.gov.uk/government/admin/speeches/#{speech.id}")

      assert_equal(speech, edition)
    end

    test "finds draft edition" do
      speech = create(:draft_speech)

      edition = AdminLinkLookup.find_edition("/government/admin/speeches/#{speech.id}")

      assert_equal(speech, edition)
    end

    test "returns nil if edition does not exist" do
      assert_nil(AdminLinkLookup.find_edition("/government/admin/speeches/1"))
    end

    test "does not find editions for pages which are not editions" do
      topic = create(:topic)

      assert_nil(AdminLinkLookup.find_edition("/government/admin/topics/#{topic.id}"))
    end

    test "does find editions for non-admin URLs" do
      assert_nil(AdminLinkLookup.find_edition("/not/a/whitehall/admin/path"))
    end
  end
end
