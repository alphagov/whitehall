namespace :rummager do
  desc "Re-index one Document. Takes a `content_id` as argument."
  task :resend_document, [:content_id] => [:environment] do |_, args|
    Document.find_by(content_id: args[:content_id]).published_edition.update_in_search_index
  end

  desc "indexes all published searchable whitehall content"
  task index: ['rummager:index:detailed', 'rummager:index:government']

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
      puts 'Getting documents related to a topical event...'
      index = Whitehall::SearchIndex.for(:government)
      related_editions = TopicalEvent.all.flat_map(&:editions).uniq
      puts 'Getting search indexes for document editions...'
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
  end

  desc "removes and re-indexes all searchable whitehall content"
  task reset: ['rummager:reset:detailed', 'rummager:reset:government']

  namespace :reset do
    task government: :environment do
      Whitehall::SearchIndex.for(:government).delete_all
      Rake::Task["rummager:index:government"].invoke
    end

    task detailed: :environment do
      Whitehall::SearchIndex.for(:detailed_guides).delete_all
      Rake::Task["rummager:index:detailed"].invoke
    end
  end
end
