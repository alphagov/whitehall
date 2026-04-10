deleted_count = 0
kept_count = 0
skipped_count = 0

Sidekiq::ScheduledSet.new
                     .select { |j| j.klass == "ScheduledPublishingJob" }
                     .group_by { |j| j.args[0] }
                     .select { |_id, jobs| jobs.size > 1 }
                     .each do |id, jobs|
                       edition = Edition.find_by(id: id)
                       unless edition
                         puts "ID: #{id} — edition not found, skipping"
                         skipped_count += 1
                         next
                       end

                       scheduled = edition.scheduled_publication&.utc
                       unless scheduled
                         puts "ID: #{id} — no scheduled_publication, skipping"
                         skipped_count += 1
                         next
                       end

                       puts "\nID: #{id} (state: #{edition.state}, scheduled_publication: #{scheduled})"

                       matching, non_matching = jobs.partition { |j| j.at == scheduled }

                       # Delete all non-matching jobs (before or after the scheduled date)
                       non_matching.each do |j|
                         puts "  Deleting non-matching job at: #{j.at}"
                         j.delete
                         deleted_count += 1
                       end

                       # Keep one matching job, delete the rest
                       if matching.any?
                         keeper = matching.shift
                         puts "  Keeping job at: #{keeper.at}"
                         kept_count += 1
                         matching.each do |j|
                           puts "  Deleting duplicate job at: #{j.at}"
                           j.delete
                           deleted_count += 1
                         end
                       else
                         puts "  ⚠️   No matching jobs found — none kept"
                       end
end

puts "\n--- Summary ---"
puts "Kept: #{kept_count}"
puts "Deleted: #{deleted_count}"
puts "Skipped: #{skipped_count}"
