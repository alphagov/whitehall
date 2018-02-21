require 'test_helper'
require "gds_api/test_helpers/publishing_api"

module OrganisationResluggerTest
  module SharedTests
    include GdsApi::TestHelpers::PublishingApi
    extend ActiveSupport::Testing::Declarative

    def self.included(klass)
      klass.use_transactional_tests = false
    end

    def setup
      stub_any_publishing_api_call
      DatabaseCleaner.clean_with :truncation
      @organisation = create_org_and_stub_content_store
      WebMock.reset! # clear the Publishing API calls after org creation
      stub_any_publishing_api_call
      @reslugger = DataHygiene::OrganisationReslugger.new(@organisation, 'corrected-slug')
    end

    def teardown
      WebMock.reset!
      DatabaseCleaner.clean_with :truncation
    end

    test "re-slugs the organisation" do
      @reslugger.run!
      assert_equal 'corrected-slug', @organisation.slug
    end

    test "publishes to Publishing API with the new slug" do
      new_base_path = "#{base_path}/corrected-slug"

      content_item = PublishingApiPresenters.presenter_for(@organisation)
      content = content_item.content
      content[:base_path] = new_base_path
      content[:routes][0][:path] = new_base_path
      content_item.stubs(content: content)

      expected_publish_requests = [
        stub_publishing_api_put_content(content_item.content_id, content_item.content),
        stub_publishing_api_patch_links(content_item.content_id, links: content_item.links),
        stub_publishing_api_publish(content_item.content_id, locale: 'en', update_type: 'major')
      ]

      Sidekiq::Testing.inline! do
        @reslugger.run!
      end

      assert_all_requested expected_publish_requests
    end

    test "deletes the old slug from the search index" do
      Whitehall::SearchIndex.expects(:delete).with { |org| org.slug == 'old-slug' }
      @reslugger.run!
    end

    test "adds the new slug from the search index" do
      Whitehall::SearchIndex.expects(:add).with { |org| org.slug == 'corrected-slug' }
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
  end

  class WorldwideOrganisationTest < ActiveSupport::TestCase
    include SharedTests

    def create_org_and_stub_content_store
      create(:worldwide_organisation, name: "Old slug")
    end

    def base_path
      "/world/organisations"
    end
  end
end
