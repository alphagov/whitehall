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

  desc "register all people with the content register"
  task :people => :environment do
    puts "Updating all People entries in the content register"

    Person.find_each do |person|
      Whitehall.content_register.put_entry(person.content_id, entry_for(person))
      print '.'
    end

    puts "\n#{Person.count} people registered with content register"
  end

  def entry_for(record)
    {
      base_path: Whitehall.url_maker.polymorphic_path(record),
      format: record.class.name.tableize,
      title: record.name,
    }
  end
end
