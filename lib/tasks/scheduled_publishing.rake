namespace :publishing do
  namespace :scheduled do
    desc "Lists editions scheduled for publication"
    task list: :environment do
      previous = nil
      puts sprintf("%6s  %-25s  %s", "ID", "Scheduled date", "Title")
      now = Time.zone.now
      Edition.scheduled.order("scheduled_publication asc").each do |edition|
        if previous && previous.scheduled_publication < now && edition.scheduled_publication >= now
          puts "----NOW----"
        end
        puts sprintf("%6s  %-25s  %s", edition.id, edition.scheduled_publication.to_s, edition.title)
        previous = edition
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

      # Consultations work slightly different to scheduled editions
      puts "Queuing consultation jobs"
      Consultation.open.or(Consultation.upcoming)
        .find_each(&:schedule_republishing_workers)
    end

    desc "Finds editions that were meant to be published between 23:00 yesterday and 01:00 today - helps debug failed publications owing to British Summer Time"
    task around_midnight: :environment do
      yesterday = Date.yesterday
      today = Time.zone.today

      time_from = Time.zone.local(yesterday.year, yesterday.month, yesterday.day, 23, 0, 0)
      time_to = Time.zone.local(today.year, today.month, today.day, 0, 0, 0)

      editions = Edition.where("scheduled_publication between ? and ?", time_from, time_to)

      puts "Document Id, Edition Id, Slug, Type"
      editions.each do |edition|
        puts "#{edition.document.id}, #{edition.id}, #{edition.slug}, #{edition.type}"
      end
    end
  end
end
