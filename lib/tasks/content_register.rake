namespace :content_register do
  desc "registers all organisations with the content register"
  task :organisations => :environment do
    puts "Updating all Organisation entries in the content register"

    Organisation.find_each do |organisation|
      Whitehall.content_register.put_entry(organisation.content_id, entry_for(organisation))
      print '.'
    end
    puts "\n#{Organisation.count} organisations registered with content register"
  end

  def entry_for(organisation)
    {
      base_path: Whitehall.url_maker.organisation_path(organisation),
      format: 'organisation',
      title: organisation.name,
    }
  end
end
