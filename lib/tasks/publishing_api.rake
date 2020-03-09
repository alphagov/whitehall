require "gds_api/publishing_api/special_route_publisher"

namespace :publishing_api do
  # this will be removed after being run once
  desc "Republish all consultations with attachments"
  task republish_consultations: :environment do
    all_consultations = Document.where(document_type: "Consultation")
    count = all_consultations.count
    all_consultations.find_each.with_index do |d, i|
      puts "#{i.fdiv(count) * 100}%"

      # this matches 4599 documents on staging
      next unless d.latest_edition
      next unless d.latest_edition.attachments.count.positive? || (d.latest_edition.outcome && d.latest_edition.outcome.attachments.count.positive?) || (d.latest_edition.public_feedback && d.latest_edition.public_feedback.attachments.count.positive?)

      PublishingApiDocumentRepublishingWorker.new.perform(d.id, true)
    end
  end

  desc "Publish special routes (eg /government)"
  task publish_special_routes: :environment do
    publisher = GdsApi::PublishingApi::SpecialRoutePublisher.new(
      logger: Logger.new(STDOUT),
      publishing_api: Services.publishing_api,
    )

    [
      {
        base_path: "/government",
        content_id: "4672b1ff-f147-4d49-a5f4-4959588da5a8",
        title: "Government prefix",
        description: "The prefix route under which almost all government content is published.",
      },
      {
        base_path: "/government/feed",
        content_id: "725a346f-9e5b-486d-873d-2b050c126e09",
        title: "Government feed",
        description: "This route serves the feed of published content",
        rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
      },
      {
        base_path: "/courts-tribunals",
        content_id: "f990c58c-687a-4baf-b1a0-ec2d02c4d654",
        title: "Courts and tribunals",
        description: "Courts and tribunals on GOV.UK.",
      },
      {
        base_path: "/api/governments",
        content_id: "2d5bafcc-2c45-4a84-8fbc-525b75dd6d19",
        title: "Governments API",
        description: "API exposing all governments on GOV.UK.",
      },
      {
        base_path: "/api/world-locations",
        content_id: "2a63b605-77be-4af5-932d-224a054dd5a5",
        title: "World Locations API",
        description: "API exposing all world locations on GOV.UK.",
      },
      {
        base_path: "/api/worldwide-organisations",
        content_id: "736f8a5a-ce6f-4a6f-b0cb-954442aa23c1",
        title: "Worldwide Organisations API",
        description: "API exposing all worldwide organisations on GOV.UK.",
      },
    ].each do |route|
      publisher.publish(
        {
          format: "special_route",
          publishing_app: "whitehall",
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          update_type: "major",
          type: "prefix",
          public_updated_at: Time.zone.now.iso8601,
        }.merge(route),
      )
    end
  end

  desc "Send published item links to Publishing API."
  task patch_published_item_links: :environment do
    editions = Edition.published
    count = editions.count
    puts "# Sending #{count} published editions to Publishing API"

    editions.pluck(:id).each_with_index do |item_id, i|
      PublishingApiLinksWorker.perform_async(item_id)

      puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
    end

    puts "Finished queuing items for Publishing API"
  end

  desc "Send links for all organisations to Publishing API."
  task patch_organisation_links: :environment do
    count = Organisation.count
    puts "# Sending links for #{count} organisations to Publishing API"

    Organisation.pluck(:id).each_with_index do |item_id, i|
      item = Organisation.find(item_id)

      Whitehall::PublishingApi.patch_links(item, bulk_publishing: true)

      puts "Processing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
    end

    puts "Finished sending links for all organisations to Publishing API"
  end

  desc "Republish an organisation to the Publishing API"
  task :republish_organisation, [:slug] => :environment do |_, args|
    organisation = Organisation.find_by!(slug: args[:slug])
    organisation.publish_to_publishing_api
  end

  desc "Republish all organisations"
  task republish_all_organisations: :environment do
    Organisation.find_each(&:publish_to_publishing_api)
  end

  desc "Republish all About pages"
  task republish_all_about_pages: :environment do
    about_us_pages = Organisation.all.map(&:about_us).compact
    count = about_us_pages.count
    puts "# Sending #{count} 'about us' pages to Publishing API"
    about_us_pages.each_with_index do |about_us_page, i|
      PublishingApiDocumentRepublishingWorker.new.perform(
        about_us_page.document_id,
        true, # bulk_publishing
      )
      puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
    end
    puts "Finished queuing items for Publishing API"
  end

  desc "Republish a person to the Publishing API"
  task :republish_person, [:slug] => :environment do |_, args|
    Person.find_by!(slug: args[:slug]).publish_to_publishing_api
  end

  desc "Republish all people to the Publishing API"
  task republish_all_people: :environment do
    Person.find_each(&:publish_to_publishing_api)
  end

  desc "Republish a role to the Publishing API"
  task :republish_role, [:slug] => :environment do |_, args|
    Role.find_by!(slug: args[:slug]).publish_to_publishing_api
  end

  desc "Republish all roles to the Publishing API"
  task republish_all_roles: :environment do
    Role.find_each(&:publish_to_publishing_api)
  end

  desc "Republish all role appointments to the Publishing API"
  task republish_all_role_appointments: :environment do
    RoleAppointment.find_each(&:publish_to_publishing_api)
  end

  desc "Send withdrawn item links to Publishing API."
  task patch_withdrawn_item_links: :environment do
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
  task patch_draft_item_links: :environment do
    editions = Edition.draft
    count = editions.count
    puts "# Sending #{count} draft editions to Publishing API"

    editions.pluck(:id).each_with_index do |item_id, i|
      PublishingApiLinksWorker.perform_async(item_id)

      puts "Queuing #{i}-#{i + 99} of #{count} items" if (i % 100).zero?
    end

    puts "Finished queuing items for Publishing API"
  end

  desc "Send publishable item links of a specific type to Publishing API (ie, 'CaseStudy')."
  task :publishing_api_patch_links_by_type, [:document_type] => :environment do |_, args|
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

  desc "Republish all documents with official attachments"
  task republish_documents_with_official_attachments: :environment do
    attachment_scope = Attachment.where("unnumbered_command_paper = true OR command_paper_number != '' OR unnumbered_hoc_paper = true OR hoc_paper_number != ''")
    edition_ids = attachment_scope.where(attachable_type: "Edition").distinct.pluck(:attachable_id)
    response_ids = attachment_scope.where(attachable_type: "Response").distinct.pluck(:attachable_id)
    edition_ids += Response.where(id: response_ids).pluck(:edition_id)
    document_ids = Document.joins(:editions).where("editions.id": edition_ids).pluck(:document_id).uniq

    puts "# Sending #{document_ids.count} documents to Publishing API"

    document_ids.each do |doc_id|
      PublishingApiDocumentRepublishingWorker.perform_async(doc_id)
    end
  end

  desc "Republish a document to the Publishing API"
  task :republish_document, [:slug] => :environment do |_, args|
    document = Document.find_by!(slug: args[:slug])
    PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  end

  def ensure_document_with_content_id_doesnt_exist(content_id)
    document = Document.find_by(content_id: content_id)

    return unless document

    puts "Document with this content ID exists: #{document}"
    abort "This Rake task is only for unknown content"
  end

  desc "Manually unpublish content with a redirect"
  # This task is for unpublishing Whitehall managed content where
  # Whitehall has forgotten it is managing the content (as it often
  # does). Do not use this Rake task for content which Whitehall still
  # has a record of.
  namespace :unpublish_with_redirect do
    task :dry_run, %i[content_id alternative_path locale] => :environment do |_, args|
      args.with_defaults(locale: "en")

      ensure_document_with_content_id_doesnt_exist(args[:content_id])

      puts "Would send an unpublish request to the Publishing API for #{args[:content_id]} with:"
      puts "  type 'redirect', locale: #{args[:locale]} and alternative_path #{args[:alternative_path].strip}"
    end

    task :real, %i[content_id alternative_path locale] => :environment do |_, args|
      args.with_defaults(locale: "en")

      ensure_document_with_content_id_doesnt_exist(args[:content_id])

      response = Services.publishing_api.unpublish(
        args[:content_id],
        type: "redirect",
        locale: args[:locale],
        alternative_path: args[:alternative_path].strip,
      )

      puts response
    end
  end

  desc "Redirect HTML Attachments to a given URL"
  namespace :redirect_html_attachments do
    task :dry, %i[content_id destination] => :environment do |_, args|
      DataHygiene::PublishingApiHtmlAttachmentRedirector.call(args[:content_id], args[:destination], dry_run: true)
    end

    task :real, %i[content_id destination] => :environment do |_, args|
      DataHygiene::PublishingApiHtmlAttachmentRedirector.call(args[:content_id], args[:destination], dry_run: false)
    end
  end

  desc "Patch links for html publications to include primary_publishing_organisation"
  task patch_html_publication_links: :environment do
    scope = Publicationesque.publicly_visible
    count = scope.count
    attachment_count = 0
    puts "# Sending HTML attachments for #{count} publications to Publishing API"
    scope.each_with_index do |pub, i|
      pub.html_attachments.each do |attachment|
        Whitehall::PublishingApi.patch_links(attachment, bulk_publishing: true)
        attachment_count += 1
      rescue StandardError => e
        puts e.inspect
      end
      puts "Processing #{i}-#{i + 99} of #{count} publications - #{attachment_count} attachments updated" if (i % 100).zero?
    end
    puts "Finished sending HTML Attachments to publishing API"
  end

  desc "Discard all draft about pages that have the same base_path as their WorldwideOrganisation"
  task discard_draft_worldwide_organisation_about_pages: :environment do
    about_pages = YAML.load_file(Rails.root.join("lib/tasks/about_pages.yml"))

    about_pages.each do |content_id, locale|
      PublishingApiDiscardDraftWorker.perform_async(content_id, locale)
    end
  end
end
