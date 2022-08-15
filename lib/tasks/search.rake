namespace :search do
  desc "Re-index one Document. Takes a `content_id` as argument."
  task :resend_document, [:content_id] => [:environment] do |_, args|
    Document.find_by(content_id: args[:content_id]).live_edition.update_in_search_index
  end

  desc "Re-index a collection of Documents with specified world location. Takes a `world_location_slug` as argument."
  task :resend_documents_in_world_location, [:world_location_slug] => [:environment] do |_, args|
    world_location = WorldLocation.find_by(slug: args[:world_location_slug])

    if world_location
      content_ids = Edition.in_world_location(world_location.id).map(&:content_id)

      Document.where(content_id: content_ids).each do |document|
        document.live_edition.try(:update_in_search_index)
      end
    else
      puts "World location for #{args[:world_location_slug]} not found"
    end
  end

  desc "indexes all published searchable whitehall content"
  task index: ["search:index:detailed", "search:index:government"]

  namespace :index do
    desc "indexes all organisations"
    task organisations: :environment do
      index = Whitehall::SearchIndex.for(:government)
      index.add_batch(Organisation.search_index)
      index.commit
    end

    desc "indexes all published searchable content for the main government index (i.e. excluding detailed guides)"
    task government: :environment do
      index = Whitehall::SearchIndex.for(:government)
      index.add_batch(RummagerPresenters.present_all_government_content)
      index.commit
    end

    desc "indexes all published detailed guides"
    task detailed: :environment do
      index = Whitehall::SearchIndex.for(:detailed_guides)
      index.add_batch(RummagerPresenters.present_all_detailed_content)
      index.commit
    end

    # NOTE: Run hourly to ensure consultation state is reflected in the search results
    desc "indexes consultations that opened or closed in the past 2 hours"
    task consultations: :environment do
      index = Whitehall::SearchIndex.for(:government)
      index.add_batch(Consultation.published.opened_at_or_after(2.hours.ago).map(&:search_index))
      index.add_batch(Consultation.published.closed_at_or_after(2.hours.ago).map(&:search_index))
      index.commit
    end

    # useful if a topical event changes and we want to change related docs
    desc "indexes all topical events and related documents"
    task topical_event_editions: :environment do
      puts "Getting documents related to a topical event..."
      index = Whitehall::SearchIndex.for(:government)
      related_editions = TopicalEvent.all.flat_map(&:editions).uniq
      puts "Getting search indexes for document editions..."
      related_edition_search_indexes = related_editions.lazy.map(&:search_index)
      puts "Adding batch of #{related_editions.count} documents to indexing queue..."
      index.add_batch(related_edition_search_indexes)
      puts "Done adding those documents to the queue; the indexing will now occur asynchronously."
      index.commit
    end

    desc "indexes all withdrawn content"
    task withdrawn: :environment do
      Edition.where(state: "withdrawn").each do |ed|
        puts "Indexing: #{ed.content_id}"
        Whitehall::SearchIndex.add(ed)
      end
      puts "Complete."
    end

    desc "indexes all content belonging to a model"
    task :model, [:model_name] => :environment do |_, args|
      model_name = args[:model_name]

      begin
        model = model_name.constantize
      rescue NameError
        raise "You need to specify a valid model name, not \"#{model_name}\""
      end

      raise "#{model_name} doesn't seem to be searchable" unless model.respond_to? :search_index

      model.all.each do |ed|
        puts "Indexing: #{ed.content_id}"
        Whitehall::SearchIndex.add(ed)
      end
      puts "Complete."
    end

    desc "indexes all documents which were last updated in the given date range, the time defaults to midnight if only a date is given"
    task :published_between, %i[start_date end_date] => :environment do |_t, args|
      Document
        .joins(:live_edition)
        .where(editions: { updated_at: args[:start_date]..args[:end_date] })
        .find_each { |doc| doc.live_edition&.update_in_search_index }
    end
  end

  desc "Update search index for all political content"
  task political: :environment do
    Edition
      .where(political: true, state: "published")
      .find_each { |edition| edition&.update_in_search_index }
  end

  desc "removes and re-indexes all searchable whitehall content"
  task reset: ["search:reset:detailed", "search:reset:government"]

  namespace :reset do
    desc "Reset the 'government' index"
    task government: :environment do
      Whitehall::SearchIndex.for(:government).delete_all
      Rake::Task["search:index:government"].invoke
    end

    desc "Reset the 'detailed' index"
    task detailed: :environment do
      Whitehall::SearchIndex.for(:detailed_guides).delete_all
      Rake::Task["search:index:detailed"].invoke
    end
  end

  desc "indexes statistics announcements"
  task statistics_announcements: :environment do
    index = Whitehall::SearchIndex.for(:government)
    index.add_batch(StatisticsAnnouncement.without_published_publication.map(&:search_index))
    index.commit
  end
end
