namespace :remove_advisory_from_editions do
  desc "Process advisory govspeak in published editions"
  task published_editions: :environment do
    regex = Regexp.new(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m).to_s

    successes = []
    failures = []
    published_content_containing_advisory_govspeak = []

    puts "\nProcessing published editions...\n"

    Edition
      .where(state: "published")
      .joins("RIGHT JOIN edition_translations ON edition_translations.edition_id = editions.id")
      .where("body REGEXP ?", regex)
      .find_each do |object|
        published_content_containing_advisory_govspeak << object.document_id
      end

    published_content_containing_advisory_govspeak.each do |document_id|
      edition = Document.find(document_id).latest_edition
      # should you be passing in the edition here rather than the document_id?
      Govspeak::RemoveAdvisoryService.new(document_id, regex).process!
      successes << edition.content_id
      print "S"
    rescue StandardError => e
      failures << { content_id: edition.content_id, error: e.message }
      print "F"
    end

    summarize_results(successes, failures)
  end

  desc "Process advisory govspeak in published HTML attachments"
  task published_html_attachments: :environment do
    regex = Regexp.new(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m)

    successes = []
    failures = []

    puts "\nProcessing published HTML attachments...\n"

    HtmlAttachment
      .joins(:govspeak_content)
      .where(deleted: false)
      .where.not(attachable: nil)
      .where("body REGEXP '#{regex.source}'")
      .find_each do |attachment|
        Govspeak::RemoveAdvisoryService.new(attachment, regex).process!
        successes << attachment.content_id
        print "S"
    rescue StandardError => e
      failures << { content_id: attachment.content_id, error: e.message }
      print "F"
      end

    summarize_results(successes, failures)
  end

  # desc "Dry run for advisory govspeak in published editions and HTML attachments"
  # task dry_run_published_editions: :environment do
  #   regex = Regexp.new(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m).to_s

  #   successes = []

  #   puts "\nDry run for published editions and HTML attachments...\n"

  #   Edition
  #     .where(state: "published")
  #     .joins("RIGHT JOIN edition_translations ON edition_translations.edition_id = editions.id")
  #     .where("body REGEXP ?", regex)
  #     .find_each do |edition|
  #       matches = edition.body.scan(regex)
  #       successes << { content_id: edition.content_id, matches: matches.count } if matches.any?
  #     end

  #   HtmlAttachment
  #     .joins(:govspeak_content)
  #     .where(deleted: false)
  #     .where.not(attachable: nil)
  #     .where("govspeak_contents.body REGEXP ?", regex)
  #     .find_each do |attachment|
  #       matches = attachment.body.scan(regex)
  #       successes << { content_id: attachment.content_id, matches: matches.count } if matches.any?
  #     end

  #   puts "Dry run results:\n"
  #   successes.each do |result|
  #     puts "Content ID: #{result[:content_id]}, Matches: #{result[:matches]}"
  #   end
  #   puts "\nDry run complete. Processed #{successes.count} items."
  # end

  def summarize_results(successes, failures)
    puts "\n\nSummary:\n"
    puts "Successes: #{successes.count}"
    puts "Failures: #{failures.count}"
    failures.each do |failure|
      puts "Failed Content ID: #{failure[:content_id]}, Error: #{failure[:error]}"
    end
  end
end
