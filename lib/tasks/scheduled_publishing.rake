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

    desc "Publish all editions due for publication"
    task :publish => :environment do
      begin
        ScheduledEditionsPublisher.publish_all_due_editions
      rescue ScheduledEditionsPublisher::PublishingFailure => exception
        Airbrake.notify_or_ignore(exception, parameters: { unpublished_editions: exception.unpublished_edition_ids })
      end
    end
  end
end
