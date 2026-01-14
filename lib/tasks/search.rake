namespace :search do
  desc "resend an organisation to search. Do not use for e.g. reslugging where the existing entry needs to first be deleted from search"
  task :resend_organisation, [:content_id] => [:environment] do |_, args|
    Organisation.find_by(content_id: args[:content_id]).update_in_search_index
  end

  desc "indexes all published searchable whitehall content"
  task index: ["search:index:detailed", "search:index:government"]

  namespace :index do
    desc "indexes all published searchable content for the main government index"
    task government: :environment do
      index = Whitehall::SearchIndex.for(:government)
      index.add_batch(SearchApiPresenters.present_all_government_content)
      index.commit
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

      model.all.find_each do |ed|
        puts "Indexing: #{ed.content_id}"
        Whitehall::SearchIndex.add(ed)
      end
      puts "Complete."
    end
  end

  desc "removes and re-indexes all searchable whitehall content"
  task reset: ["search:reset:government"]

  namespace :reset do
    desc "Reset the 'government' index"
    task government: :environment do
      Whitehall::SearchIndex.for(:government).delete_all
      Rake::Task["search:index:government"].invoke
    end
  end

  desc "indexes statistics announcements"
  task statistics_announcements: :environment do
    index = Whitehall::SearchIndex.for(:government)
    index.add_batch(StatisticsAnnouncement.without_published_publication.map(&:search_index))
    index.commit
  end
end
