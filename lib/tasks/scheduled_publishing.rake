namespace :publishing do
  namespace :scheduled do
    desc "Clears all scheduled publishing jobs then requeues all scheduled editions (and open/close actions for editions that 'HasOpeningAndClosingDates'). This task is intended to be used after a db restore or in the event of the Sidekiq queue being emptied."
    task requeue_all_jobs: :environment do
      ScheduledPublishingJob.dequeue_all

      puts "Queueing #{Edition.scheduled.count} jobs"
      Edition.scheduled.each do |edition|
        ScheduledPublishingJob.queue(edition)
        print "."
      end
      puts ""

      # Consultations and Calls for Evidence work slightly different to scheduled editions
      puts "Queuing Consultation jobs"
      Consultation.open.or(Consultation.upcoming)
        .find_each(&:schedule_republishing_jobs)

      puts "Queuing CallForEvidence jobs"
      CallForEvidence.open.or(CallForEvidence.upcoming)
        .find_each(&:schedule_republishing_jobs)
    end
  end
end
