require "test_helper"

class PublishingApiRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable # without this, calling `invoke` does nothing after first test
  end

  describe "#publish_special_routes" do
    let(:task) { Rake::Task["publishing_api:publish_special_routes"] }

    test "publishes each special route" do
      Timecop.freeze do
        params = {
          format: "special_route",
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          update_type: "major",
          type: "prefix",
          public_updated_at: Time.zone.now.iso8601,
        }

        SpecialRoute.all.each do |route| # rubocop:disable Rails/FindEach
          GdsApi::PublishingApi::SpecialRoutePublisher
            .any_instance.expects(:publish).with(params.merge(route))
        end

        capture_io { task.invoke }
      end
    end
  end

  describe "#publish_redirect_routes" do
    let(:task) { Rake::Task["publishing_api:publish_redirect_routes"] }

    test "publishes each redirect route" do
      Timecop.freeze do
        RedirectRoute.all.each do |route| # rubocop:disable Rails/FindEach
          params = {
            base_path: route[:base_path],
            document_type: "redirect",
            schema_name: "redirect",
            locale: "en",
            details: {},
            redirects: [
              {
                path: route[:base_path],
                type: route.fetch(:type, "prefix"),
                destination: route[:destination],
              },
            ],
            publishing_app: Whitehall::PublishingApp::WHITEHALL,
            public_updated_at: Time.zone.now.iso8601,
            update_type: "major",
          }
          capture_io { task.invoke }
          assert_publishing_api_put_content(route[:content_id], params)
          assert_publishing_api_publish(route[:content_id])
        end
      end
    end
  end

  describe "patch_links" do
    describe "#organisations" do
      let(:task) { Rake::Task["publishing_api:patch_links:organisations"] }

      test "patches links for organisations" do
        # Organisation needs to be created before the method is stubed
        organisation = create(:organisation)

        Whitehall::PublishingApi.expects(:patch_links).with(
          organisation, bulk_publishing: true
        ).once
        capture_io { task.invoke }
      end
    end

    describe "#published_editions" do
      let(:task) { Rake::Task["publishing_api:patch_links:published_editions"] }

      test "patches links for published editions" do
        edition = create(:edition, :published)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        capture_io { task.invoke }
      end
    end

    describe "#withdrawn_editions" do
      let(:task) { Rake::Task["publishing_api:patch_links:withdrawn_editions"] }

      test "sends withdrawn item links to Publishing API" do
        edition = create(:edition, :withdrawn)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        capture_io { task.invoke }
      end
    end

    describe "#draft_editions" do
      let(:task) { Rake::Task["publishing_api:patch_links:draft_editions"] }

      test "sends draft item links to Publishing API" do
        edition = create(:edition)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        capture_io { task.invoke }
      end
    end

    describe "#by_type" do
      let(:task) { Rake::Task["publishing_api:patch_links:by_type"] }

      test "sends item links to Publishing API from document type" do
        edition = create(:published_publication)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        capture_io { task.invoke("Publication") }
      end
    end
  end

  describe "unpublish" do
    describe "#by_content_id" do
      let(:task) { Rake::Task["publishing_api:unpublish:by_content_id"] }

      test "unpublishes and redirects document" do
        content_id = SecureRandom.uuid
        path = "/some-random-path"
        locale = "en"

        request = stub_publishing_api_unpublish(
          content_id,
          body: {
            type: "redirect",
            locale:,
            alternative_path: path,
          },
        )

        capture_io { task.invoke(content_id, path, locale) }

        assert_requested request
      end
    end
  end

  describe "redirect_unpublished_statistics_announcement" do
    let(:task) { Rake::Task["publishing_api:redirect_unpublished_statistics_announcement"] }

    test "does not redirect when there is no statistics announcement found" do
      request = stub_any_publishing_api_unpublish

      out, _err = capture_io { task.invoke("unknown-slug", "https://www.test.gov.uk/government/new") }

      assert_not_requested request
      assert_equal "Could not find Statistics Announcement with slug unknown-slug", out.strip
    end

    test "does not redirect when there are multiple statistics announcement found" do
      sa1 = create(:unpublished_statistics_announcement, slug: "same-slug", redirect_url: "https://www.test.gov.uk/government/old")
      sa2 = create(:unpublished_statistics_announcement, slug: "same-slug", redirect_url: "https://www.test.gov.uk/government/old")
      request = stub_any_publishing_api_unpublish

      out, _err = capture_io { task.invoke("same-slug", "https://www.test.gov.uk/government/new") }

      assert_not_requested request
      assert_equal "More than one Statistics Announcement (including Unpublished) with slug same-slug", out.strip
      assert_equal sa1.reload.redirect_url, "https://www.test.gov.uk/government/old"
      assert_equal sa2.reload.redirect_url, "https://www.test.gov.uk/government/old"
    end

    test "does not redirect when statistics announcement is not unpublished" do
      statistics_announcement = create(:statistics_announcement, redirect_url: "https://www.test.gov.uk/government/old")
      request = stub_any_publishing_api_unpublish

      out, _err = capture_io { task.invoke(statistics_announcement.slug, "https://www.test.gov.uk/government/new") }

      assert_not_requested request
      assert_equal "Statistics Announcement with slug #{statistics_announcement.slug} is not unpublished", out.strip
      assert_equal statistics_announcement.reload.redirect_url, "https://www.test.gov.uk/government/old"
    end

    test "redirects statistics announcement and updates the redirect_url" do
      statistics_announcement = create(:unpublished_statistics_announcement, redirect_url: "https://www.test.gov.uk/government/old")

      request = stub_publishing_api_unpublish(
        statistics_announcement.content_id,
        body: {
          type: "redirect",
          locale: "en",
          alternative_path: "https://www.test.gov.uk/government/new",
        },
      )

      out, _err = capture_io { task.invoke(statistics_announcement.slug, "https://www.test.gov.uk/government/new") }

      assert_requested request
      assert_includes out, "Unpublishing from Publishing API..."
      assert_equal statistics_announcement.reload.redirect_url, "https://www.test.gov.uk/government/new"
    end
  end

  describe "redirect_html_attachments" do
    describe "#by_content_id" do
      let(:task) { Rake::Task["publishing_api:redirect_html_attachments:by_content_id"] }

      test "redirects HTML attachments" do
        content_id = SecureRandom.uuid
        path = "/some-random-path"

        DataHygiene::PublishingApiHtmlAttachmentRedirector.expects(:call).with(
          content_id,
          path,
          dry_run: false,
        )

        capture_io { task.invoke(content_id, path) }
      end
    end
  end
end
