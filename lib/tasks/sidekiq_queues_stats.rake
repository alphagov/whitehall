desc "display Sidekiq job stats across all queues and sets"
task sidekiq_queues_stats: :environment do
  # Total jobs across all active queues
  total_enqueued = Sidekiq::Stats.new.enqueued

  puts "\nEnqueued Jobs (Active Queues)"
  puts "------------------------------------"
  all_queues = Sidekiq::Queue.all
  all_queues.each do |q|
    puts "#{q.name}: #{q.size}"
  end
  puts "Total: #{total_enqueued}"

  # Total jobs in the various sets
  scheduled_set = Sidekiq::ScheduledSet.new
  retry_set = Sidekiq::RetrySet.new
  dead_set = Sidekiq::DeadSet.new
  total_scheduled = scheduled_set.size
  total_retries = retry_set.size
  total_dead = dead_set.size

  puts "\nTotal Jobs Across All Sets"
  puts "--------------------------"
  puts "Scheduled: #{total_scheduled}"
  puts "Retries: #{total_retries}"
  puts "Dead: #{total_dead}"
  puts "Total: #{total_scheduled + total_retries + total_dead}"

  puts "\nJob Count Grouped by Class and Queue"
  puts "------------------------------------"
  # Scheduled Jobs
  puts "\nScheduled Jobs (Set: Sidekiq::ScheduledSet)"
  scheduled_counts = get_job_counts(scheduled_set)
  scheduled_counts.each { |(klass, queue), count| puts "  #{klass} (Queue: #{queue}): #{count}" }

  # Retried Jobs
  puts "\nRetried Jobs (Set: Sidekiq::RetrySet)"
  retry_counts = get_job_counts(retry_set)
  retry_counts.each { |(klass, queue), count| puts "  #{klass} (Queue: #{queue}): #{count}" }

  # Dead Jobs
  puts "\nDead Jobs (Set: Sidekiq::DeadSet)"
  dead_counts = get_job_counts(dead_set)
  dead_counts.each { |(klass, queue), count| puts "  #{klass} (Queue: #{queue}): #{count}" }
end

def get_job_counts(set)
  set.each_with_object(Hash.new(0)) do |job, counts|
    counts[[job.klass, job.queue]] += 1
  end
end
