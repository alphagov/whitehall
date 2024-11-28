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

    desc "Clears all scheduled publishing jobs then requeues all scheduled editions (and open/close actions for editions that 'HasOpeningAndClosingDates'). This task is intended to be used after a db restore or in the event of the Sidekiq queue being emptied."
    task requeue_all_jobs: :environment do
      ScheduledPublishingWorker.dequeue_all

      puts "Queueing #{Edition.scheduled.count} jobs"
      Edition.scheduled.each do |edition|
        ScheduledPublishingWorker.queue(edition)
        print "."
      end
      puts ""

      # Consultations and Calls for Evidence work slightly different to scheduled editions
      puts "Queuing Consultation jobs"
      Consultation.open.or(Consultation.upcoming)
        .find_each(&:schedule_republishing_workers)

      puts "Queuing CallForEvidence jobs"
      CallForEvidence.open.or(CallForEvidence.upcoming)
        .find_each(&:schedule_republishing_workers)
    end
  end
end
