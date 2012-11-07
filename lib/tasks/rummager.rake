namespace :rummager do
  desc "Reindex published documents"
  task :index => ['rummager:index:detailed', 'rummager:index:government']

  namespace :index do
    task :warn_about_no_op do
      if Rails.env.development? && ENV["RUMMAGER_HOST"].blank?
        puts "Note: not actually submitting content to Rummager. Set RUMMAGER_HOST if you want to do so." 
      end
    end

    task :government => [:environment, :warn_about_no_op] do
      Rummageable.index(Whitehall.government_search_index, Whitehall.government_search_index_name)
      Rummageable.commit(Whitehall.government_search_index_name)
    end

    task :detailed => [:environment, :warn_about_no_op] do
      Rummageable.index(Whitehall.detailed_guidance_search_index, Whitehall.detailed_guidance_search_index_name)
      Rummageable.commit(Whitehall.detailed_guidance_search_index_name)
    end
  end
end
