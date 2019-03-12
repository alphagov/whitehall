namespace :publishing do
  namespace :scheduled do
    desc "Lists editions scheduled for publication"
    task list: :environment do
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

    desc "Counts scheduled publications for the next 8 weeks"
    task next_8_weeks: :environment do
      scheduled = Edition.scheduled
      now = Time.zone.now
      end_of_this_week = now.end_of_week
      monday = now.beginning_of_week + 1.week
      sunday = end_of_this_week + 1.week
      past_scheduled_count = scheduled.where("scheduled_publication < ?", now).count
      rest_of_the_week_count = scheduled.where("scheduled_publication >= ?", now).where("scheduled_publication < ?", end_of_this_week).count
      puts "---"
      puts "There are currently #{scheduled.count} scheduled publications in Whitehall."
      puts "Of all the scheduled publications:"
      puts " - #{past_scheduled_count} were scheduled before now (#{now.rfc822})"
      puts " - #{rest_of_the_week_count} are scheduled between now (#{now.rfc822}) and the end of this week (#{end_of_this_week.rfc822})"
      8.times do
        weekly_count = scheduled.where("scheduled_publication >= ?", monday).where("scheduled_publication < ?", sunday).count
        puts " - #{weekly_count} are scheduled in the week beginning on #{monday.rfc822}"
        monday += 1.week
        sunday += 1.week
      end
      remaining_count = scheduled.where("scheduled_publication >= ?", monday).count
      puts " - #{remaining_count} are scheduled on or after #{monday.rfc822}"
      puts "---"
    end

    desc "Queues missing jobs for any scheduled editions (including overdue ones)"
    task queue_missing_jobs: :environment do
      queued_ids      = ScheduledPublishingWorker.queued_edition_ids
      missing_jobs    = Edition.scheduled.reject { |edition| queued_ids.include?(edition.id) }
      puts "#{Edition.scheduled.count} editions scheduled for publication, of which #{missing_jobs.size} do not have a job."

      puts "Queueing missing jobs..."
      missing_jobs.each do |edition|
        ScheduledPublishingWorker.queue(edition)
        puts "#{edition.id} queued"
      end
    end

    desc "Clears all jobs then requeues all scheduled editions (intended for use after a db restore)"
    task requeue_all_jobs: :environment do
      ScheduledPublishingWorker.dequeue_all

      puts "Queueing #{Edition.scheduled.count} jobs"
      Edition.scheduled.each do |edition|
        ScheduledPublishingWorker.queue(edition)
        print "."
      end
      puts ""
    end

    desc "Finds editions that were meant to be published between 23:00 yesterday and 01:00 today - helps debug failed publications owing to British Summer Time"
    task around_midnight: :environment do
      yesterday = Date.yesterday
      today = Date.today

      time_from = Time.new(yesterday.year, yesterday.month, yesterday.day, 23, 0, 0)
      time_to = Time.new(today.year, today.month, today.day, 0, 0, 0)

      editions = Edition.where("scheduled_publication between ? and ?", time_from, time_to)

      puts "Document Id, Edition Id, Slug, Type"
      editions.each do |edition|
        puts "#{edition.document.id}, #{edition.id}, #{edition.slug}, #{edition.type}"
      end
    end
  end

  namespace :overdue do
    desc "List scheduled editions overdue for publication by more than one minute"
    task list: :environment do
      puts "%6s  %-25s  %s" % ["ID", "Scheduled date", "Title"]
      Edition.due_for_publication(1.minute).each do |edition|
        puts "%6s  %-25s  %s" % [edition.id, edition.scheduled_publication.to_s, edition.title]
      end
    end

    desc "Publishes scheduled editions overdue for publication by more than one minute"
    task publish: :environment do
      Edition.due_for_publication(1.minute).each do |edition|
        puts "Publishing overdue scheduled edition #{edition.id}"
        ScheduledPublishingWorker.new.perform(edition.id)
      end
    end
  end
end
