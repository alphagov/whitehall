desc "display Sidekiq job stats across all queues and sets"
task sidekiq_queues_stats: :environment do |_, _args|
  # Total jobs across all active queues
  total_enqueued = Sidekiq::Stats.new.enqueued

  # Total jobs in the various sets
  total_scheduled = Sidekiq::ScheduledSet.new.size
  total_retries = Sidekiq::RetrySet.new.size
  total_dead = Sidekiq::DeadSet.new.size

  puts "\nTotal Jobs Across All Sets"
  puts "--------------------------"
  puts "Enqueued (All Queues): #{total_enqueued}"
  puts "Scheduled: #{total_scheduled}"
  puts "Retries: #{total_retries}"
  puts "Dead: #{total_dead}"
  puts "Total: #{total_enqueued + total_scheduled + total_retries + total_dead}"

  puts "\nJob Count Grouped by Class and Queue"
  puts "------------------------------------"

  # Scheduled Jobs
  scheduled_set = Sidekiq::ScheduledSet.new
  scheduled_counts = get_job_counts(scheduled_set)
  puts "\nScheduled Jobs (Set: Sidekiq::ScheduledSet)"
  scheduled_counts.each { |(klass, queue), count| puts "  #{klass} (Queue: #{queue}): #{count}" }

  # Retried Jobs
  retry_set = Sidekiq::RetrySet.new
  retry_counts = get_job_counts(retry_set)
  puts "\nRetried Jobs (Set: Sidekiq::RetrySet)"
  retry_counts.each { |(klass, queue), count| puts "  #{klass} (Queue: #{queue}): #{count}" }

  # Dead Jobs
  dead_set = Sidekiq::DeadSet.new
  dead_counts = get_job_counts(dead_set)
  puts "\nDead Jobs (Set: Sidekiq::DeadSet)"
  dead_counts.each { |(klass, queue), count| puts "  #{klass} (Queue: #{queue}): #{count}" }

  def get_job_counts(set)
    set.each_with_object(Hash.new(0)) do |job, counts|
      counts[[job.klass, job.queue]] += 1
    end
  end
end
