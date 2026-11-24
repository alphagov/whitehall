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
  end

  class OrganisationTest < ActiveSupport::TestCase
    include SharedTests

    def create_org_and_stub_content_store
      create(:organisation, name: "Old slug")
    end

    def base_path
      "/government/organisations"
    end

    test "republishes the documents of all the organisation's corporate information pages, once each" do
      published_page = create(:published_corporate_information_page, organisation: @organisation)
      draft_of_published_page = create(
        :draft_corporate_information_page,
        organisation: @organisation,
        document: published_page.document,
        corporate_information_page_type_id: published_page.corporate_information_page_type_id,
      )
      draft_only_page = create(
        :draft_corporate_information_page,
        organisation: @organisation,
        corporate_information_page_type_id: CorporateInformationPageType::ComplaintsProcedure.id,
      )
      assert_equal published_page.document, draft_of_published_page.document

      Whitehall::PublishingApi.stubs(:republish_document_async)
      Whitehall::PublishingApi.expects(:republish_document_async).with(published_page.document).once
      Whitehall::PublishingApi.expects(:republish_document_async).with(draft_only_page.document).once

      @reslugger.run!
    end

    test "updates users belonging to the organisation" do
      user = create(:user, organisation_slug: @organisation.slug)

      @reslugger.run!

      user.reload
      assert_equal user.organisation_slug, "corrected-slug"
    end
  end
end
