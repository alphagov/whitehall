require "test_helper"

class BulkRepublisherTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#republish_all_documents" do
    test "queues all documents for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        document = create(:document)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents
    end

    test "doesn't queue non-editionable content" do
      BulkRepublisher.any_instance.stubs(:non_editionable_content_types).returns(%w[Contact Role])

      Whitehall::PublishingApi.expects(:bulk_republish_async).with(create(:contact)).never
      Whitehall::PublishingApi.expects(:bulk_republish_async).with(create(:role)).never

      Contact.any_instance.stubs(:can_publish_to_publishing_api?).returns(true)
      Role.any_instance.stubs(:can_publish_to_publishing_api?).returns(true)

      BulkRepublisher.new.republish_all_documents
    end

    test "doesn't queue individual pages" do
      [
        "PublishingApi::HistoricalAccountsIndexPresenter",
        "PublishingApi::HowGovernmentWorksPresenter",
        "PublishingApi::OperationalFieldsIndexPresenter",
        "PublishingApi::MinistersIndexPresenter",
        "PublishingApi::EmbassiesIndexPresenter",
        "PublishingApi::WorldIndexPresenter",
        "PublishingApi::OrganisationsIndexPresenter",
      ].each do |presenter|
        PresentPageToPublishingApiWorker
          .expects(:perform_async)
          .with(presenter)
          .never
      end

      BulkRepublisher.new.republish_all_documents
    end
  end

  describe "#republish_all_documents_with_pre_publication_editions" do
    test "queues all documents with pre-publication editions for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        document_with_pre_publication_edition = create(:document, editions: [build(:published_edition), build(:draft_edition)])

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document_with_pre_publication_edition.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions
    end

    test "doesn't queue documents without pre-publication editions for republishing" do
      document = create(:document, editions: [build(:published_edition)])

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions
    end
  end

  describe "#republish_all_documents_with_pre_publication_editions_with_html_attachments" do
    test "queues all documents with pre-publication editions with HTML attachments for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        draft_edition = build(:draft_edition)
        document = create(:document, editions: [build(:published_edition), draft_edition])
        create(:html_attachment, attachable_type: "Edition", attachable_id: draft_edition.id)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions_with_html_attachments
    end

    test "doesn't queue documents for republishing if the editions with HTML attachments aren't pre-publication editions" do
      document = create(:document, editions: [build(:published_edition)])
      create(:html_attachment, attachable_type: "Edition", attachable_id: document.live_edition_id)

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions_with_html_attachments
    end

    test "doesn't queue documents republishing when there are pre-publication editions but none have HTML attachments" do
      document = create(:document, editions: [build(:published_edition), build(:draft_edition)])

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_pre_publication_editions_with_html_attachments
    end
  end

  describe "#republish_all_documents_with_publicly_visible_editions_with_attachments" do
    test "queues all documents with publicly-visible editions with attachments for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        document = create(:document, editions: [build(:published_edition), build(:draft_edition)])
        create(:attachment, attachable_type: "Edition", attachable_id: document.live_edition.id)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_attachments
    end

    test "doesn't queue documents for republishing if the editions with attachments aren't publicly-visible editions" do
      draft_edition = build(:draft_edition)
      document = create(:document, editions: [draft_edition])
      create(:attachment, attachable_type: "Edition", attachable_id: draft_edition.id)

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_attachments
    end

    test "doesn't queue documents republishing when there are publicly-visible editions but none have attachments" do
      document = create(:document, editions: [build(:published_edition), build(:draft_edition)])

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_attachments
    end
  end

  describe "#republish_all_documents_with_publicly_visible_editions_with_html_attachments" do
    test "queues all documents with publicly-visible editions with HTML attachments for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        document = create(:document, editions: [build(:published_edition), build(:draft_edition)])
        create(:html_attachment, attachable_type: "Edition", attachable_id: document.live_edition.id)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document.id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_html_attachments
    end

    test "doesn't queue documents for republishing if the editions with HTML attachments aren't publicly-visible editions" do
      draft_edition = build(:draft_edition)
      document = create(:document, editions: [draft_edition])
      create(:html_attachment, attachable_type: "Edition", attachable_id: draft_edition.id)

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_html_attachments
    end

    test "doesn't queue documents republishing when there are publicly-visible editions but none have HTML attachments" do
      document = create(:document, editions: [build(:published_edition), build(:draft_edition)])

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", document.id, true)
        .never

      BulkRepublisher.new.republish_all_documents_with_publicly_visible_editions_with_html_attachments
    end
  end

  describe "#republish_all_non_editionable_content" do
    test "queues all non-editionable content for republishing, excluding individual pages" do
      BulkRepublisher.any_instance.stubs(:non_editionable_content_types).returns(%w[Contact Role])

      Whitehall::PublishingApi.expects(:bulk_republish_async).with(create(:contact))
      Whitehall::PublishingApi.expects(:bulk_republish_async).with(create(:role))

      Contact.any_instance.stubs(:can_publish_to_publishing_api?).returns(true)
      Role.any_instance.stubs(:can_publish_to_publishing_api?).returns(true)

      BulkRepublisher.new.republish_all_non_editionable_content
    end

    test "doesn't queue documents" do
      2.times do
        document = create(:document)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", document.id, true)
          .never
      end

      BulkRepublisher.new.republish_all_non_editionable_content
    end

    test "doesn't queue individual pages" do
      [
        "PublishingApi::HistoricalAccountsIndexPresenter",
        "PublishingApi::HowGovernmentWorksPresenter",
        "PublishingApi::OperationalFieldsIndexPresenter",
        "PublishingApi::MinistersIndexPresenter",
        "PublishingApi::EmbassiesIndexPresenter",
        "PublishingApi::WorldIndexPresenter",
        "PublishingApi::OrganisationsIndexPresenter",
      ].each do |presenter|
        PresentPageToPublishingApiWorker
          .expects(:perform_async)
          .with(presenter)
          .never
      end

      BulkRepublisher.new.republish_all_non_editionable_content
    end
  end

  describe "#republish_all_published_organisation_about_us_pages" do
    test "queues all published organisation 'About us' pages for republishing" do
      queue_sequence = sequence("queue")

      2.times do
        about_us_page = create(:about_corporate_information_page)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", about_us_page.document_id, true)
          .in_sequence(queue_sequence)
      end

      BulkRepublisher.new.republish_all_published_organisation_about_us_pages
    end

    test "doesn't queue draft organisation 'About us' pages for republishing" do
      about_us_page = create(:draft_about_corporate_information_page)

      PublishingApiDocumentRepublishingWorker
        .expects(:perform_async_in_queue)
        .with("bulk_republishing", about_us_page.document_id, true)
        .never

      BulkRepublisher.new.republish_all_published_organisation_about_us_pages
    end
  end

  describe "#republish_all_by_type" do
    setup do
      BulkRepublisher.any_instance.stubs(:non_editionable_content_types).returns(%w[Contact])
      BulkRepublisher.any_instance.stubs(:republishable_content_types).returns(%w[Contact CaseStudy])
    end

    context "for editionable content types, like CaseStudy" do
      test "republishes all content of the specified type via the PublishingApiDocumentRepublishingWorker" do
        2.times do
          case_study = create(:case_study)
          PublishingApiDocumentRepublishingWorker.expects(:perform_async_in_queue).with(
            "bulk_republishing",
            case_study.document_id,
            true,
          )
        end
        BulkRepublisher.new.republish_all_by_type("CaseStudy")
      end
    end

    context "for non-editionable content types, like Contact, when publishable to Publishing API" do
      test "republishes all content of the specified type via the Whitehall::Publishing API" do
        2.times do
          contact = create(:contact)
          Contact.any_instance.stubs(:can_publish_to_publishing_api?).returns(true)
          Whitehall::PublishingApi.expects(:bulk_republish_async).with(contact)
        end
        BulkRepublisher.new.republish_all_by_type("Contact")
      end
    end

    context "for non-editionable content types, like Contact, when not publishable to Publishing API" do
      test "does not republish content of the specified type via the Whitehall::Publishing API" do
        2.times do
          contact = create(:contact)
          Contact.any_instance.stubs(:can_publish_to_publishing_api?).returns(false)
          Whitehall::PublishingApi.expects(:bulk_republish_async).with(contact).never
        end
        BulkRepublisher.new.republish_all_by_type("Contact")
      end
    end

    context "for non-republishable model types" do
      test "it raises an error" do
        assert_raises(StandardError, match: "Unknown content type User") do
          BulkRepublisher.new.republish_all_by_type("User")
        end
      end
    end

    context "for non-existent content types" do
      test "it raises an error" do
        assert_raises(StandardError, match: "Unknown content type SomeDocumentTypeThatDoesntExist") do
          BulkRepublisher.new.republish_all_by_type("SomeDocumentTypeThatDoesntExist")
        end
      end
    end
  end

  describe "#republish_all_documents_by_organisation" do
    context "with a given organisation" do
      test "republishes each of the organisation's documents" do
        organisation = create(:organisation)
        documents = create_list(:document, 3)

        documents.each do |document|
          create(:published_news_article, document:, organisations: [organisation])

          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async_in_queue)
            .with("bulk_republishing", document.id, true)
        end

        BulkRepublisher.new.republish_all_documents_by_organisation(organisation)
      end

      test "doesn't republish editions for other organisations" do
        organisation = create(:organisation)
        other_organisation = create(:organisation)
        documents = create_list(:document, 3)

        documents.each do |document|
          create(:published_news_article, document:, organisations: [other_organisation])

          PublishingApiDocumentRepublishingWorker
            .expects(:perform_async_in_queue)
            .with("bulk_republishing", document.id, true)
            .never
        end

        BulkRepublisher.new.republish_all_documents_by_organisation(organisation)
      end
    end

    context "when the organisation argument is not an organisation" do
      test "raises an error" do
        edition = create(:edition)

        assert_raises(StandardError, match: "Argument must be an organisation") do
          BulkRepublisher.new.republish_all_documents_by_organisation(edition)
        end
      end
    end
  end

  describe "#republish_all_documents_by_ids" do
    test "republishes documents with the given IDs" do
      ids = [1, 2, 3, 4, 5]

      ids.each do |id|
        create(:document, id:)

        PublishingApiDocumentRepublishingWorker
          .expects(:perform_async_in_queue)
          .with("bulk_republishing", id, true)
          .once
      end

      BulkRepublisher.new.republish_all_documents_by_ids(ids)
    end
  end
end
