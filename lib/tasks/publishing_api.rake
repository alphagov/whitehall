require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  desc "Publish special routes (eg /government)"
  task publish_special_routes: :environment do
    publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: Logger.new($stdout),
      publishing_api: Services.publishing_api,
    )

    SpecialRoute.all.each do |route|
      publisher.publish(
        {
          format: "special_route",
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          update_type: "major",
          type: "prefix",
          public_updated_at: Time.zone.now.iso8601,
        }.merge(route),
      )
    end
  end

  desc "Publish redirect routes (eg /government/world)"
  task publish_redirect_routes: :environment do
    RedirectRoute.all.each do |route|
      Services.publishing_api.put_content(
        route[:content_id],
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
      )
      Services.publishing_api.publish(route[:content_id])
    end
  end

  namespace :republish do
    desc "Republish an organisation to the Publishing API"
    task :organisation_by_slug, [:slug] => :environment do |_, args|
      Organisation.find_by!(slug: args[:slug]).publish_to_publishing_api
    end

    desc "Republish a person to the Publishing API"
    task :person_by_slug, [:slug] => :environment do |_, args|
      Person.find_by!(slug: args[:slug]).publish_to_publishing_api
    end

    desc "Republish a role to the Publishing API"
    task :role_by_slug, [:slug] => :environment do |_, args|
      Role.find_by!(slug: args[:slug]).publish_to_publishing_api
    end

    desc "Republish a document to the Publishing API"
    task :document_by_slug, [:slug] => :environment do |_, args|
      document = Document.find_by!(slug: args[:slug])
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
    end

    desc "Republish the past prime ministers index page to Publishing API"
    task republish_past_prime_ministers_index: :environment do
      PresentPageToPublishingApi.new.publish(PublishingApi::HistoricalAccountsIndexPresenter)
    end

    desc "Republish the how government works page to Publishing API"
    task republish_how_government_works: :environment do
      PresentPageToPublishingApi.new.publish(PublishingApi::HowGovernmentWorksPresenter)
    end

    desc "Republish the fields of operation index page to Publishing API"
    task republish_operational_fields_index: :environment do
      PresentPageToPublishingApi.new.publish(PublishingApi::OperationalFieldsIndexPresenter)
    end

    desc "Republish the ministers index page to Publishing API"
    task republish_ministers_index: :environment do
      PresentPageToPublishingApi.new.publish(PublishingApi::MinistersIndexPresenter)
    end

    desc "Republish the embassies index page to Publishing API"
    task republish_embassies_index: :environment do
      PresentPageToPublishingApi.new.publish(PublishingApi::EmbassiesIndexPresenter)
    end
  end

  namespace :patch_links do
    desc "Send links for all organisations to Publishing API."
    task organisations: :environment do
      count = Organisation.count
      puts "# Sending links for #{count} organisations to Publishing API"

      Organisation.pluck(:id).each_with_index do |item_id, i|
        item = Organisation.find(item_id)

        Whitehall::PublishingApi.patch_links(item, bulk_publishing: true)

        puts "Processing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
      end

      puts "Finished sending links for all organisations to Publishing API"
    end

    desc "Send published editions links to Publishing API."
    task published_editions: :environment do
      editions = Edition.published
      count = editions.count
      puts "# Sending #{count} published editions to Publishing API"

      editions.pluck(:id).each_with_index do |item_id, i|
        PublishingApiLinksWorker.perform_async(item_id)

        puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
      end

      puts "Finished queuing items for Publishing API"
    end

    desc "Send withdrawn item links to Publishing API."
    task withdrawn_editions: :environment do
      editions = Edition.withdrawn
      count = editions.count
      puts "# Sending #{count} withdrawn editions to Publishing API"

      editions.pluck(:id).each_with_index do |item_id, i|
        PublishingApiLinksWorker.perform_async(item_id)

        puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
      end

      puts "Finished queuing items for Publishing API"
    end

    desc "Send draft item links to Publishing API."
    task draft_editions: :environment do
      editions = Edition.draft
      count = editions.count
      puts "# Sending #{count} withdrawn editions to Publishing API"

      editions.pluck(:id).each_with_index do |item_id, i|
        PublishingApiLinksWorker.perform_async(item_id)

        puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
      end
    end

    desc "Send publishable item links of a specific type to Publishing API (ie, 'CaseStudy')."
    task :by_type, [:document_type] => :environment do |_, args|
      document_type = args[:document_type]
      editions = document_type.constantize.published
      count = editions.count
      puts "# Sending #{count} published editions to Publishing API"

      editions.pluck(:id).each_with_index do |item_id, i|
        PublishingApiLinksWorker.perform_async(item_id)

        puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
      end

      puts "Finished queuing items for Publishing API"
    end
  end

  namespace :bulk_republish do
    desc "Republish all About pages"
    task all_about_pages: :environment do
      about_us_pages = Organisation.all.map(&:about_us).compact
      count = about_us_pages.count
      puts "# Sending #{count} 'about us' pages to Publishing API"
      about_us_pages.each_with_index do |about_us_page, i|
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
          "bulk_republishing",
          about_us_page.document_id,
          true,
        )
        puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
      end
      puts "Finished queuing items for Publishing API"
    end

    desc "Republish all documents with draft editions"
    task all_drafts: :environment do
      editions = Edition.in_pre_publication_state.includes(:document)

      puts "Enqueueing #{editions.count} documents"
      editions.find_each do |edition|
        document_id = edition.document.id
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
      end
      puts "Finished enqueueing items for Publishing API"
    end

    desc "Republish all editions which have attachments to the Publishing API"
    task editions_with_attachments: :environment do
      editions = Edition.publicly_visible.where(
        id: Attachment.where(accessible: false, attachable_type: "Edition").select("attachable_id"),
      )

      editions.joins(:document).distinct.pluck("documents.id").each do |document_id|
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
      end
    end

    desc "⚠️  WARNING: this rake task republishes **all** documents with HTML attachments (this can block publishing for > 1 hour) ⚠️. Republish all documents with HTML attachments to the Publishing API."
    task html_attachments: :environment do
      document_ids = Edition
        .publicly_visible
        .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
        .pluck(:document_id)
      document_ids.each do |document_id|
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
      end
    end

    desc "Republish all draft editions with HTML attachments to the Publishing API"
    task drafts_with_html_attachments: :environment do
      document_ids = Edition
        .in_pre_publication_state
        .where(id: HtmlAttachment.where(attachable_type: "Edition").select(:attachable_id))
        .pluck(:document_id)
      document_ids.each do |document_id|
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document_id, true)
      end
    end

    desc "Republish all documents of a given type, e.g. 'NewsArticle'"
    task :document_type, [:document_type] => :environment do |_, args|
      begin
        document_type = args[:document_type].constantize
      rescue NameError
        abort "Unknown document type #{args[:document_type]}\nCheck the GOV.UK developer documentation for a list of acceptable document types: https://docs.publishing.service.gov.uk/manual/republishing-content.html#whitehall"
      end

      documents = document_type.all
      puts "Enqueueing #{documents.count} documents"
      documents.find_each do |document|
        if document.respond_to?(:publish_to_publishing_api)
          Whitehall::PublishingApi.bulk_republish_async(document)
        else
          PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document.document_id, true)
        end
      end
      puts "Finished enqueueing items for Publishing API"
    end

    desc "Republish all documents of a given organisation"
    task :by_organisation, [:organisation_slug] => :environment do |_, args|
      org = Organisation.find_by(slug: args[:organisation_slug])
      editions = Edition.latest_edition.in_organisation(org)
      puts "Enqueueing #{editions.count} documents"
      editions.find_each do |edition|
        document = edition.document
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document.id, true)
      end
      puts "Finished enqueueing items for Publishing API"
    end

    desc "Republish documents by content id"
    task :documents_by_content_ids, %w[content_ids] => :environment do |_, args|
      content_ids =  args[:content_ids].split
      document_ids = Document.where(content_id: content_ids).pluck(:id)

      puts "Bulk republishing #{document_ids.count} documents"

      document_ids.each do |id|
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id, true)
      end
    end

    desc "Republish documents by content ids from CSV"
    task :documents_by_content_ids_from_csv, [:csv_file_name] => :environment do |_, args|
      csv = CSV.read(Rails.root.join("lib/tasks/#{args[:csv_file_name]}.csv"), headers: true)
      content_ids = csv["content_id"].uniq
      document_ids = Document.where(content_id: content_ids).pluck(:id)

      puts "Bulk republishing #{document_ids.count} documents"

      document_ids.each do |id|
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id, true)
      end
    end

    desc "Republish all documents"
    task all_documents: :environment do
      puts "Enqueueing #{Document.count} documents"
      Document.find_each do |document|
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", document.id, true)
      end
      puts "Finished enqueueing items for Publishing API"
    end
  end

  namespace :unpublish do
    desc "Manually unpublish content with a redirect"
    # This task is for unpublishing Whitehall managed content where
    # Whitehall has forgotten it is managing the content (as it often
    # does). Do not use these Rake tasks for content which Whitehall still
    # has a record of.
    task :by_content_id, %i[content_id alternative_path locale] => :environment do |_, args|
      args.with_defaults(locale: "en")

      document = Document.find_by(content_id: args[:content_id])
      abort "Document with this content ID exists: #{document}" if document

      response = Services.publishing_api.unpublish(
        args[:content_id],
        type: "redirect",
        locale: args[:locale],
        alternative_path: args[:alternative_path].strip,
      )

      puts response
    end
  end

  namespace :redirect_html_attachments do
    desc "Redirect HTML Attachments to a given URL (dry run)"
    task :by_content_id_dry_run, %i[content_id destination] => :environment do |_, args|
      DataHygiene::PublishingApiHtmlAttachmentRedirector.call(args[:content_id], args[:destination], dry_run: true)
    end

    desc "Redirect HTML Attachments to a given URL (for reals)"
    task :by_content_id, %i[content_id destination] => :environment do |_, args|
      DataHygiene::PublishingApiHtmlAttachmentRedirector.call(args[:content_id], args[:destination], dry_run: false)
    end
  end
end
