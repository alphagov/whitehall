namespace :governments do
  desc "Update links for all content tagged to a government"
  task relink: :environment do
    STDOUT.sync = true
    Edition.where.not(state: %w[deleted superseded]).find_each do |edition|
      presenter = PublishingApiPresenters.presenter_for(edition)
      begin
        links = presenter.links

        if links[:government].present?
          print "."

          Services.publishing_api.patch_links(
            presenter.content_id,
            links: links.slice(:government),
            bulk_publishing: true,
          )
        end
      rescue StandardError => e
        puts "\nFAIL #{e.class} (#{e.message}) for document: #{presenter.content_id}"
      end
    end
    puts
  end
end
