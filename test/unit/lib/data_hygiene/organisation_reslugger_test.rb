require "test_helper"
require "gds_api/test_helpers/publishing_api"

module OrganisationResluggerTest
  module SharedTests
    include GdsApi::TestHelpers::PublishingApi
    extend ActiveSupport::Testing::Declarative

    def setup
      stub_any_publishing_api_call
      @organisation = create_org_and_stub_content_store
      WebMock.reset! # clear the Publishing API calls after org creation
      stub_any_publishing_api_call
      @reslugger = DataHygiene::OrganisationReslugger.new(@organisation, "corrected-slug")
    end

    def teardown
      WebMock.reset!
    end

    test "re-slugs the organisation" do
      @reslugger.run!
      assert_equal "corrected-slug", @organisation.slug
    end

    test "publishes to Publishing API with the new slug" do
      new_base_path = "#{base_path}/corrected-slug"
      new_atom_base_path = "#{base_path}/corrected-slug.atom"

      content_item = PublishingApiPresenters.presenter_for(@organisation)
      content = content_item.content
      content[:base_path] = new_base_path
      content[:routes][0][:path] = new_base_path
      content[:routes][1][:path] = new_atom_base_path unless content[:routes][1].nil?
      content_item.stubs(content:)

      expected_publish_requests = [
        stub_publishing_api_put_content(content_item.content_id, content_item.content),
        stub_publishing_api_publish(content_item.content_id, locale: "en", update_type: nil),
      ]

      Sidekiq::Testing.inline! do
        @reslugger.run!
      end

      assert_all_requested expected_publish_requests
    end

    test "deletes the old slug from the search index" do
      Whitehall::SearchIndex.expects(:delete).with { |org| org.slug == "old-slug" }
      @reslugger.run!
    end

    test "adds the new slug from the search index" do
      Whitehall::SearchIndex.expects(:add).with { |org| org.slug == "corrected-slug" }
      @reslugger.run!
    end
  end

  class OrganisationTest < ActiveSupport::TestCase
    include SharedTests

    def create_org_and_stub_content_store
      create(:organisation, name: "Old slug")
    end

    def base_path
      "/government/organisations"
    end

    test "updates users belonging to the organisation" do
      user = create(:user, organisation_slug: @organisation.slug)

      @reslugger.run!

      user.reload
      assert_equal user.organisation_slug, "corrected-slug"
    end

    test "re-registers editions belonging to the organisation" do
      edition = create(:published_corporate_information_page, :published, organisation: @organisation)

      Whitehall::SearchIndex.stubs(:add)
      Whitehall::SearchIndex.expects(:add).with edition
      @reslugger.run!
    end

    test "when an organisation has child and parent organisations, it also resends these to search api" do
      child_organisation = create(:organisation, name: "child slug")
      parent_organisation = create(:organisation, name: "parent slug")
      organisation = create(:organisation, name: "ye olde slug", child_organisations: [child_organisation], parent_organisations: [parent_organisation])
      reslugger = DataHygiene::OrganisationReslugger.new(organisation, "corrected-slug")

      Whitehall::SearchIndex.expects(:delete).with(organisation)
      Whitehall::SearchIndex.expects(:add).with { |org| org.slug == "corrected-slug" }
      Whitehall::SearchIndex.expects(:add).with(child_organisation)
      Whitehall::SearchIndex.expects(:add).with(parent_organisation)

      reslugger.run!
    end
  end

  class WorldwideOrganisationTest < ActiveSupport::TestCase
    include SharedTests

    def create_org_and_stub_content_store
      create(:worldwide_organisation, name: "Old slug")
    end

    def base_path
      "/world/organisations"
    end

    test "calls update_editions" do
      @reslugger.expects(:update_editions).once
      @reslugger.run!
    end
  end
end
