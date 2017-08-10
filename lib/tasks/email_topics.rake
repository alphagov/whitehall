namespace :email_topics do
  task :check, [:content_id] => :environment do |_task, args|
    document = Document.find_by!(content_id: args.content_id)
    puts EmailTopicChecker.new(document).check
  end

  task check_all_documents: :environment do
    Document.published.find_in_batches(batch_size: 20).each do |documents|
      threads = documents.map do |document|
        checker = EmailTopicChecker.new(document, verbose: false)

        Thread.new do
          begin
            failed_content_id = checker.check
            puts failed_content_id if failed_content_id
            print "."
          rescue StandardError => ex
            puts "#{document.content_id} raised #{ex.message}"
          end
        end
      end

      threads.each(&:join)
    end
  end
end
