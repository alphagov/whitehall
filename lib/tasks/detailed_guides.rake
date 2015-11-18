namespace :detailed_guides do
  desc "Generates a CSV report of the statuses of all Detailed Guides"
  task report: :environment do
    Rails.logger = Logger.new(STDERR)
    GdsApi::Base.logger = Rails.logger

    panopticon = GdsApi::Panopticon.new(Plek.find('panopticon'), PANOPTICON_API_CREDENTIALS)
    router_api = GdsApi::Router.new(Plek.find('router-api'))

    scope = Document.where(document_type: "DetailedGuide").order(:slug)
    count = scope.count
    i = 0

    CSV(STDOUT) do |csv|
      csv << %w[
        slug
        deleted_prefix
        latest_edition_state
        published_edition_state
        unpublishing_state
        unpublishing_alternative
        unpublishing_redirect
        root_url
        namespaced_url
        panopticon_issue
        panopticon_state
      ]
      scope.find_each do |document|
        slug = document.slug.sub(%r{^deleted-}, '')

        Rails.logger.info "#{i += 1} / #{count}"

        row = [
          slug,
          (document.slug =~ %r{^deleted-}).present?,
          document.latest_edition.try(:state) || "missing",
          document.published_edition.try(:state) || "missing"
        ]

        unpublishing = Unpublishing.find_by(edition_id: document.latest_edition.try(:id)) ||
          Unpublishing.from_slug(slug, "DetailedGuide")

        if unpublishing
          row += [
            unpublishing.unpublishing_reason.name,
            unpublishing.alternative_url,
            unpublishing.redirect
          ]
        else
          row += ["none", nil, nil]
        end
        root_route = router_api.get_route("/#{slug}")
        namespaced_route = router_api.get_route("/guidance/#{slug}")

        [root_route, namespaced_route].each do |route|
          if route.nil?
            row << "missing"
          elsif route["handler"] == "redirect"
            row << route["redirect_to"]
          elsif route["handler"] == "gone"
          row << "gone"
          elsif route["handler"] == "backend"
            row << route["backend_id"]
          end
        end

        root_artefact = panopticon.artefact_for_slug("#{slug}") rescue nil
        namespaced_artefact = panopticon.artefact_for_slug("guidance/#{slug}") rescue nil

        if root_artefact && namespaced_artefact
          row << "duplicated"
        elsif root_artefact
          row << "unmigrated"
        elsif root_artefact.nil? && namespaced_artefact.nil?
          row << "missing"
        elsif namespaced_artefact["paths"].sort != ["/guidance/#{slug}", "/#{slug}"].sort
          row << "missing paths"
        else
          row << "ok"
        end

        row << namespaced_artefact.try(:state)

        csv << row
      end
    end
  end

  desc "Push root redirects to Content Store"
  task publish_root_redirects: :environment do
    def publish_redirects(slug, redirects)
      redirect_items = redirects.map do |from, to|
        {path: from, destination: to, type: "exact"}
      end
      Whitehall::PublishingApi.publish_redirect_async("/#{slug}", redirect_items)
    rescue GdsApi::HTTPClientError => e
      puts "Couldn't publish redirect for #{slug}: #{e.message}"
    end

    scope = Document.where(document_type: "DetailedGuide")
    count = scope.count
    i = 0
    scope.find_each do |document|
      slug = document.slug.sub(%r{^deleted-}, '')

      published_edition = document.published_edition

      unpublishing = Unpublishing.find_by(edition_id: published_edition.try(:id)) ||
        Unpublishing.from_slug(slug, "DetailedGuide")

      path = "/#{slug}"
      puts "Processing #{path} #{i+=1}/#{count}"

      if published_edition || (unpublishing && !unpublishing.redirect?)
        edition = published_edition || unpublishing.edition
        paths = edition.translated_locales.map do |locale|
          "/#{slug}.#{locale}".chomp(".en")
        end
        puts "Redirecting #{paths.join(", ")} to new namespace"
        redirects = Hash[paths.map { |path| [path, "/guidance#{path}"] }]
        publish_redirects(slug, redirects)
      elsif unpublishing && unpublishing.redirect?
        paths = unpublishing.edition.translated_locales.map do |locale|
          "/#{slug}.#{locale}".chomp(".en")
        end
        alternative_path = URI.parse(unpublishing.alternative_url).path
        puts "Redirecting #{paths.join(", ")} to #{alternative_path}"
        redirects = Hash[paths.map { |path| [path, alternative_path] }]
        publish_redirects(slug, redirects)
      else
        puts "Skipping /#{slug} as never published"
      end
    end
  end
end
