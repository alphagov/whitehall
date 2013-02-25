namespace :publishing do
  namespace :scheduled do
    desc "List editions scheduled for publication"
    task :list => :environment do
      previous = nil
      puts "%6s  %-25s  %s" % ["ID", "Scheduled date", "Title"]
      now = Time.zone.now
      Edition.scheduled.order("scheduled_publication asc").each do |edition|
        if previous && previous.scheduled_publication < now && edition.scheduled_publication >= now
          puts "----NOW----"
        end
        puts "%6s  %-25s  %s" % [edition.id, edition.scheduled_publication.to_s, edition.title]
        previous = edition
      end
    end
  end

  namespace :due do
    desc "List editions due for publication"
    task :list => :environment do
      puts "%6s  %-25s  %s" % ["ID", "Scheduled date", "Title"]
      Edition.due_for_publication.each do |edition|
        puts "%6s  %-25s  %s" % [edition.id, edition.scheduled_publication.to_s, edition.title]
      end
    end

    desc "Show the number of overdue publications in Nagios format"
    task :check => :environment do
      num_overdue = Edition.due_for_publication.count
      if num_overdue > 0
        puts "CRITICAL: There are #{num_overdue} overdue Whitehall publications"
        # Nagios expects an exit code of 2 for CRITICAL
        exit 2
      else
        puts "OK: There are 0 overdue Whitehall publications"
        # Nagios expects an exit code of 0 for OK
        exit 0
      end
    end

    desc "Publish all editions due for publication"
    task :publish => :environment do
      Edition.publish_all_due_editions_as(Edition.scheduled_publishing_robot)
    end
  end
end
