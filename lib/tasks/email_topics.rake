namespace :email_topics do
  task :check, [:content_id] => :environment do |_task, args|
    content_id = args.content_id
    document = Document.find_by(content_id: content_id)
    puts EmailTopicChecker.check(document)
  end

  task check_all_documents: :environment do
    Document.published.find_in_batches(batch_size: 20) do |documents|
      presenters = documents.map do |document|
        PublishingApiPresenters.presenter_for(document.published_edition)
      end
      presenters.each(&:content)

      threads = presenters.map do |presented_edition|
        Thread.new do
          begin
            failed_content_id = EmailTopicChecker.check(presented_edition, false)
            puts failed_content_id if failed_content_id
            print "."
          rescue StandardError => ex
            puts "#{presented_edition.content_id} raised #{ex.message}"
          end
        end
      end
      threads.map(&:join)
    end
  end
end
