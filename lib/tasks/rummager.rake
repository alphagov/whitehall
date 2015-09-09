namespace :rummager do
  desc "indexes all published searchable whitehall content"
  task :index => ['rummager:index:detailed', 'rummager:index:government']

  namespace :index do
    desc "indexes all published searchable content for the main government index (i.e. excluding detailed guides)"
    task :government => :environment do
      index = Whitehall::SearchIndex.for(:government)
      index.add_batch(Whitehall.government_search_index)
      index.commit
    end

    desc "indexes all published detailed guiudes"
    task :detailed => :environment do
      index = Whitehall::SearchIndex.for(:detailed_guides)
      index.add_batch(Whitehall.detailed_guidance_search_index)
      index.commit
    end

    # NOTE: Run daily to ensure consultation state is reflected in the search results
    desc "indexes consultations which closed in the past day"
    task :closed_consultations => :environment do
      index = Whitehall::SearchIndex.for(:government)
      index.add_batch(Consultation.published.closed_since(25.hours.ago).map(&:search_index))
      index.commit
    end
  end

  desc "removes and re-indexes all searchable whitehall content"
  task :reset => ['rummager:reset:detailed', 'rummager:reset:government']

  namespace :reset do
    task :government => :environment do
      Whitehall::SearchIndex.for(:government).delete_all
      Rake::Task["rummager:index:government"].invoke
    end

    task :detailed => :environment do
      Whitehall::SearchIndex.for(:detailed_guides).delete_all
      Rake::Task["rummager:index:detailed"].invoke
    end
  end
end
