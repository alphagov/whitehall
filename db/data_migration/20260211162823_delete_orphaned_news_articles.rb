BATCH_SIZE = 100
SLEEP_AFTER_BATCH = 2.0
ORIGINAL_TYPE_COL = Edition.inheritance_column

target_scope = Edition.unscoped.where(type: "NewsArticle", state: "deleted")
total_records = target_scope.count

puts "Starting cleanup of #{total_records} records..."
puts "Start Time: #{Time.zone.now.strftime('%H:%M:%S')}"

begin
  Edition.inheritance_column = :_disabled_cleanup

  target_scope.find_in_batches(batch_size: BATCH_SIZE).with_index do |batch, index|
    ActiveRecord::Base.transaction do
      batch.each(&:destroy)
    end

    processed = (index + 1) * BATCH_SIZE
    puts "Committed #{processed}/#{total_records}..."

    sleep(SLEEP_AFTER_BATCH)
  end

  puts "SUCCESS: All orphaned NewsArticles have been destroyed."
rescue StandardError => e
  puts "\n!!! ERROR !!!"
  puts "Message: #{e.message}"
ensure
  Edition.inheritance_column = ORIGINAL_TYPE_COL
  puts "STI restored to #{Edition.inheritance_column}"
end
