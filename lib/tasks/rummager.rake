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

    desc "indexes all published publications with particular subtype IDs (supports multiple subtypes eg [1,2,3,4])"
    task :publications_with_subtypes, [:publication_type] => :environment do |task, args|
      publication_type_ids = [ args[:publication_type] ] + args.extras.to_a
      index = Whitehall::SearchIndex.for(:government)
      publications = Publication.published.where(publication_type_id: publication_type_ids)
      index.add_batch(publications.map(&:search_index))
      index.commit
    end

    # NOTE: Run daily to ensure consultation state is reflected in the search results
    desc "indexes consultations which closed in the past day"
    task closed_consultations: :environment do
      index = Whitehall::SearchIndex.for(:government)
      index.add_batch(Consultation.published.closed_since(25.hours.ago).map(&:search_index))
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
