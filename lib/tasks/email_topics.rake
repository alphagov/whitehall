namespace :email_topics do
  task :check, [:content_id] => :environment do |_task, args|
    content_id = args.content_id
    EmailTopicChecker.check(content_id)
  end

  task check_all_documents: :environment do
    Document.published.find_in_batches(batch_size: 4) do |documents|
      threads = documents.map do |document|
        Thread.new do
          begin
            failed_content_id = EmailTopicChecker.check_and_return_failed_content_ids(document.content_id)
            puts failed_content_id if failed_content_id
            print "."
          rescue StandardError => ex
            puts "#{document.content_id} raised #{ex.message}"
          end
        end
      end
      threads.map(&:join)
    end
  end
end
