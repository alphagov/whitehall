require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  desc "Publish special routes (eg /government)"
  task publish_special_routes: :environment do
    publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: Logger.new($stdout),
      publishing_api: Services.publishing_api,
    )

    SpecialRoute.all.each do |route| # rubocop:disable Rails/FindEach
      publisher.publish(
        {
          format: "special_route",
          publishing_app: Whitehall::PublishingApp::WHITEHALL,
          update_type: "major",
          type: "prefix",
          public_updated_at: Time.zone.now.iso8601,
        }.merge(route),
      )
    end
  end

  desc "Publish redirect routes (eg /government/world)"
  task publish_redirect_routes: :environment do
    RedirectRoute.all.each do |route| # rubocop:disable Rails/FindEach
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
