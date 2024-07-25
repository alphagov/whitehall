namespace :bulk_content_updates do
  def editions_matching_domain(domain)
    Edition
      .active
      .joins("INNER JOIN edition_translations ON edition_translations.edition_id = editions.id")
      .where("edition_translations.body LIKE ?", "%#{domain}%")
  end

  desc "Remove all links to a particular domain - "
  task :remove_links_to_domain, %i[domain mode] => :environment do |_, args|
    domain, mode = args.values_at(:domain, :mode)
    unless %w[live dry-run].include?(mode)
      raise "mode should be 'live' or 'dry-run'"
    end

    editions_matching_domain(domain).find_each do |edition|
      link_remover = Govspeak::LinkRemover.new(edition.body, domain)
      next unless link_remover.match?

      puts "Replacing links in #{edition.base_path} (#{mode})"
      puts link_remover.describe_replacements

      if mode == "dry-run"
        puts "Skipping changes in dry-run mode"
      elsif mode == "live"
        edition.body = link_remover.remove_links_for_domain
        edition.save!
        PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
          "bulk_republishing",
          edition.document_id,
          true,
        )
      end
    end
  end
end
