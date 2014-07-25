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

    desc "Queues missing jobs for any future-scheduled editions"
    task :queue_missing_jobs => :environment do
      scheduled_scope = Edition.scheduled.where(Edition.arel_table[:scheduled_publication].gteq(Time.zone.now))
      queued_ids      = ScheduledPublishingWorker.queued_edition_ids
      missing_jobs    = scheduled_scope.select { |edition| !queued_ids.include?(edition.id) }
      puts "#{scheduled_scope.count} editions scheduled for publication, of which #{missing_jobs.size} do not have a job."

      puts "Queueing missing jobs..."
      missing_jobs.each do |edition|
        ScheduledPublishingWorker.queue(edition)
        puts "#{edition.id} queued"
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
  end

  namespace :overdue do
    desc "Publishes any scheduled editions that are more than a minute past their due date"
    task :publish => :environment do
      overdue_editions = Edition.scheduled.where(Edition.arel_table[:scheduled_publication].lteq(Time.zone.now - 1.minute))

      overdue_editions.each do |edition|
        puts "Publishing overdue scheduled edition #{edition.id}"
        ScheduledPublishingWorker.new.perform(edition.id)
      end
    end
  end
end
