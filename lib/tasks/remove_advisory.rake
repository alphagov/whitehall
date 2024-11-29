namespace :remove_advisory do
  desc "Process advisory govspeak in published editions"
  task published_editions: :environment do
    regex = Govspeak::EmbeddedContentPatterns::ADVISORY.to_s
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
      Govspeak::RemoveAdvisoryService.new(edition, dry_run: false).process!
      successes << edition.content_id
      print "S"
    rescue StandardError => e
      failures << { content_id: edition.content_id, error: e.message }
      print "F"
    end

    summarize_results(successes, failures)
  end

  desc "Dry run to show which editions would have advisory govspeak processed"
  task dry_run_published_editions: :environment do
    regex = Govspeak::EmbeddedContentPatterns::ADVISORY.to_s

    successes = []
    failures = []
    published_content_containing_advisory_govspeak = []

    puts "\nStarting dry run of published editions...\n"

    Edition
      .where(state: "published")
      .joins("RIGHT JOIN edition_translations ON edition_translations.edition_id = editions.id")
      .where("body REGEXP ?", regex)
      .find_each do |object|
        published_content_containing_advisory_govspeak << object.document_id
      end

    published_content_containing_advisory_govspeak.each do |document_id|
      edition = Document.find(document_id).latest_edition
      Govspeak::RemoveAdvisoryService.new(edition, dry_run: true).process!
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
    regex = Govspeak::EmbeddedContentPatterns::ADVISORY.to_s

    successes = []
    failures = []

    puts "\nProcessing published HTML attachments...\n"

    HtmlAttachment
      .joins(:govspeak_content)
      .where(deleted: false)
      .where.not(attachable: nil)
      .where("govspeak_contents.body REGEXP ?", regex)
      .find_each do |attachment|
        next if attachment.attachable.respond_to?(:state) && attachment.attachable.state != "published"

        Govspeak::RemoveAdvisoryService.new(attachment, dry_run: false).process!
        successes << attachment.content_id
        print "S"
    rescue StandardError => e
      failures << { content_id: attachment.content_id, error: e.message }
      print "F"
      end

    summarize_results(successes, failures)
  end
end

desc "Dry run to show which HTML publications would have advisory govspeak processed"
task dry_run_published_html_attachments: :environment do
  regex = Govspeak::EmbeddedContentPatterns::ADVISORY.to_s

  successes = []
  failures = []

  puts "\nStarting dry run of published HTML attachments...\n"

  HtmlAttachment
    .joins(:govspeak_content)
    .where(deleted: false)
    .where.not(attachable: nil)
    .where("govspeak_contents.body REGEXP ?", regex)
    .find_each do |attachment|
      next if attachment.attachable.respond_to?(:state) && attachment.attachable.state != "published"

      Govspeak::RemoveAdvisoryService.new(attachment, dry_run: true).process!
      successes << attachment.content_id
      print "S"
  rescue StandardError => e
    failures << { content_id: attachment.content_id, error: e.message }
    print "F"
    end

  summarize_results(successes, failures)
end

def summarize_results(successes, failures)
  puts "\n\nSummary:\n"
  puts "Successes: #{successes.count}"
  puts "Failures: #{failures.count}"
  failures.each do |failure|
    puts "Failed Content ID: #{failure[:content_id]}, Error: #{failure[:error]}"
  end
end
