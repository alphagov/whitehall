namespace :email_topics do
  desc "check the email topics for a single document"
  task :check, [:content_id] => :environment do |_task, args|
    document = Document.find_by!(content_id: args.content_id)
    puts EmailTopicChecker.new(document).check
  end

  desc "check the email topics for all documents"
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

  desc "check the email topics for documents listed in a file (one content_id per line)"
  task :check_file, [:path] => :environment do |_task, args|
    content_ids = File.read(File.expand_path(args.path)).split
    documents = Document.where(content_id: content_ids)

    documents.find_each do |document|
      begin
        puts EmailTopicChecker.new(document).check
      rescue StandardError => ex
        puts "#{document.content_id} raised #{ex.message}"
      end
    end
  end
end
