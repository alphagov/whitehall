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
          publishing_app: "whitehall",
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          update_type: "major",
          type: "prefix",
          public_updated_at: Time.zone.now.iso8601,
        }

        SpecialRoute.all.each do |route|
          GdsApi::PublishingApi::SpecialRoutePublisher
            .any_instance.expects(:publish).with(params.merge(route))
        end

        task.invoke
      end
    end
  end

  describe "#publish_redirect_routes" do
    let(:task) { Rake::Task["publishing_api:publish_redirect_routes"] }

    test "publishes each redirect route" do
      Timecop.freeze do
        RedirectRoute.all.each do |route|
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
            publishing_app: "whitehall",
            public_updated_at: Time.zone.now.iso8601,
            update_type: "major",
          }
          task.invoke
          assert_publishing_api_put_content(route[:content_id], params)
          assert_publishing_api_publish(route[:content_id])
        end
      end
    end
  end

  describe "republish" do
    describe "#document_by_slug" do
      let(:task) { Rake::Task["publishing_api:republish:document_by_slug"] }

      test "republishes document by slug" do
        document = create(:document)
        PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(document.id)
        task.invoke(document.slug)
      end
    end

    describe "#organisation_by_slug" do
      let(:task) { Rake::Task["publishing_api:republish:organisation_by_slug"] }

      test "Republishes organisation by slug" do
        record = create(:organisation)
        Organisation.any_instance.expects(:publish_to_publishing_api)
        task.invoke(record.slug)
      end
    end

    describe "#person_by_slug" do
      let(:task) { Rake::Task["publishing_api:republish:person_by_slug"] }

      test "Republishes person by slug" do
        record = create(:person)
        Person.any_instance.expects(:publish_to_publishing_api)
        task.invoke(record.slug)
      end
    end

    describe "#role_by_slug" do
      let(:task) { Rake::Task["publishing_api:republish:role_by_slug"] }

      test "Republishes role by slug" do
        record = create(:role)
        Role.any_instance.expects(:publish_to_publishing_api)
        task.invoke(record.slug)
      end
    end

    describe "#all_organisations" do
      let(:task) { Rake::Task["publishing_api:republish:all_organisations"] }

      test "Republishes all organisations" do
        create(:organisation)
        Organisation.any_instance.expects(:publish_to_publishing_api)
        task.invoke
      end
    end

    describe "#all_people" do
      let(:task) { Rake::Task["publishing_api:republish:all_people"] }

      test "Republishes all people" do
        create(:person)
        Person.any_instance.expects(:publish_to_publishing_api)
        task.invoke
      end
    end

    describe "#all_roles" do
      let(:task) { Rake::Task["publishing_api:republish:all_roles"] }

      test "Republishes all roles" do
        create(:role)
        Role.any_instance.expects(:publish_to_publishing_api)
        task.invoke
      end
    end

    describe "#all_take_part_pages" do
      let(:task) { Rake::Task["publishing_api:republish:all_take_part_pages"] }

      test "Republishes all take part pages" do
        create(:take_part_page)
        TakePartPage.any_instance.expects(:publish_to_publishing_api)
        task.invoke
      end
    end

    describe "#all_role_appointments" do
      let(:task) { Rake::Task["publishing_api:republish:all_role_appointments"] }

      test "Republishes all role appointments" do
        create(:role_appointment)
        RoleAppointment.any_instance.expects(:publish_to_publishing_api)
        task.invoke
      end
    end
  end

  describe "patch_links" do
    describe "#organisations" do
      let(:task) { Rake::Task["publishing_api:patch_links:organisations"] }

      test "patches links for organisations" do
        Whitehall::PublishingApi.expects(:patch_links).with(
          create(:organisation), bulk_publishing: true
        ).once
        task.invoke
      end
    end

    describe "#published_editions" do
      let(:task) { Rake::Task["publishing_api:patch_links:published_editions"] }

      test "patches links for published editions" do
        edition = create(:edition, :published)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        task.invoke
      end
    end

    describe "#withdrawn_editions" do
      let(:task) { Rake::Task["publishing_api:patch_links:withdrawn_editions"] }

      test "sends withdrawn item links to Publishing API" do
        edition = create(:edition, :withdrawn)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        task.invoke
      end
    end

    describe "#draft_editions" do
      let(:task) { Rake::Task["publishing_api:patch_links:draft_editions"] }

      test "sends draft item links to Publishing API" do
        edition = create(:edition)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        task.invoke
      end
    end

    describe "#by_type" do
      let(:task) { Rake::Task["publishing_api:patch_links:by_type"] }

      test "sends item links to Publishing API from document type" do
        edition = create(:published_publication)
        PublishingApiLinksWorker.expects(:perform_async).with(edition.id)
        task.invoke("Publication")
      end
    end
  end

  describe "bulk_republish" do
    describe "#all_about_pages" do
      let(:task) { Rake::Task["publishing_api:bulk_republish:all_about_pages"] }

      test "republishes all about pages" do
        corporate_info = create(
          :published_corporate_information_page,
          corporate_information_page_type_id: CorporateInformationPageType::AboutUs.id,
        )

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          corporate_info.document_id,
          true,
        )

        task.invoke
      end
    end

    describe "#editions_with_attachments" do
      let(:task) { Rake::Task["publishing_api:bulk_republish:editions_with_attachments"] }

      test "republishes all editions with attachments" do
        edition = create(:published_publication, :with_file_attachment)

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          edition.document_id,
          true,
        )
        task.invoke
      end
    end

    describe "#html_attachments" do
      let(:task) { Rake::Task["publishing_api:bulk_republish:html_attachments"] }

      test "republishes all documents with HMTL attachments" do
        edition = create(:published_publication, :with_html_attachment)

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          edition.document_id,
          true,
        )
        task.invoke
      end
    end

    describe "#document_type" do
      let(:task) { Rake::Task["publishing_api:bulk_republish:document_type"] }

      test "republishes all documents of the specified document type" do
        edition = create(:publication)

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          edition.document_id,
          true,
        )
        task.invoke("Publication")
      end
    end

    describe "#by_organisation" do
      let(:org) { create(:organisation) }
      let(:task) { Rake::Task["publishing_api:bulk_republish:by_organisation"] }

      test "Republishes the latest edition for each document owned by the organisation" do
        edition = create(:published_news_article, organisations: [org])

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          edition.document.id,
          true,
        )

        task.invoke(org.slug)
      end

      test "Ignores documents owned by other organisations" do
        some_other_org = create(:organisation)
        edition = create(:published_news_article, organisations: [some_other_org])

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          edition.document.id,
          true,
        ).never

        task.invoke(org.slug)
      end
    end

    describe "#documents_by_content_ids" do
      let(:task) { Rake::Task["publishing_api:bulk_republish:documents_by_content_ids"] }

      test "Republishes documents by content ids" do
        edition = create(:publication)

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          edition.document.id,
          true,
        )

        task.invoke([edition.content_id])
      end
    end

    describe "#documents_by_content_ids_from_csv" do
      let(:task) { Rake::Task["publishing_api:bulk_republish:documents_by_content_ids_from_csv"] }

      test "Republishes documents by content ids from csv" do
        edition = create(:publication)
        filename = "content_ids_#{Time.zone.now.to_i}"

        File.write("lib/tasks/#{filename}.csv", "content_id\n#{edition.content_id}")

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          edition.document.id,
          true,
        )

        task.invoke(filename)

        File.delete("lib/tasks/#{filename}.csv")
      end
    end

    describe "#all_documents" do
      let(:task) { Rake::Task["publishing_api:bulk_republish:all_documents"] }

      test "Republishes all documents" do
        publication = create(:published_publication)
        news_story = create(:published_news_story)

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          news_story.document_id,
          true,
        )

        PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
          "bulk_republishing",
          publication.document_id,
          true,
        )

        task.invoke
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
            locale: locale,
            alternative_path: path,
          },
        )

        task.invoke(content_id, path, locale)

        assert_requested request
      end
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

        task.invoke(content_id, path)
      end
    end
  end
end
