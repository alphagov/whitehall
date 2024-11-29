namespace :remove_advisory_from_editions do
  desc "A temporary rake task to change instances of advisory in govspeak in published edition's body into information callouts, and then republish the editions"
  task published_editions: :environment do
    published_content_containing_advisory_govspeak = []

    regex = Regexp.new(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m).to_s

    Edition
      .where(state: "published")
      .joins("RIGHT JOIN edition_translations ON edition_translations.edition_id = editions.id")
      .where("body REGEXP ?", regex)
      .find_each do |object|
        published_content_containing_advisory_govspeak << object.content_id
      end

    puts published_content_containing_advisory_govspeak.count
    unfound_docs = []

    published_content_containing_advisory_govspeak.each do |content_id|
      record = Document.find_by(content_id:)

      unless record
        puts "No document found for content_id: #{content_id}"
        unfound_docs << content_id
        next
      end

      slug = record.slug
      edition = record.live_edition
      body = edition.body

      puts "Processing #{slug}"

      matches = body.scan(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m)

      next unless matches.any?

      puts "Matches found: #{matches.size}"

      new_body = body.gsub(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m) do
        content = Regexp.last_match(1)
        "^#{content}^"
      end

      if new_body != body
        edition.update!(minor_change: true)

        edition.update!(body: new_body)

        puts "Modified body for #{slug}"
      end
    end

    puts unfound_docs

    published_content_containing_advisory_govspeak.each do |edition|
      PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)
      Whitehall::PublishingApi.republish_document_async(edition.document, bulk: true)
    end
  end

  desc "A temporary rake task to change instances of advisory in govspeak in published HTML attachment's body into information callouts, and then republish the editions"
  task published_html_attachments: :environment do
    published_content_containing_advisory_govspeak = []

    regex = Regexp.new(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m).to_s

    HtmlAttachment
      .joins(:govspeak_content)
      .where(deleted: false)
      .where.not(attachable: nil)
      .where("govspeak_contents.body REGEXP ?", regex)
      .find_each do |object|
        next unless object.attachable.state == "published"

        published_content_containing_advisory_govspeak << object.content_id
    end

    puts published_content_containing_advisory_govspeak.count
    unfound_docs = []

    published_content_containing_advisory_govspeak.each do |content_id|
      record = Attachment.find_by(content_id:)

      unless record
        puts "No attachment found for content_id: #{content_id}"
        unfound_docs << content_id
        next
      end

      slug = record.slug
      edition = record.live_edition
      body = record.body

      puts "Processing #{slug}"

      matches = body.scan(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m)

      next unless matches.any?

      puts "Matches found: #{matches.size}"

      new_body = body.gsub(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m) do
        content = Regexp.last_match(1)
        "^#{content}^"
      end

      if new_body != body
        edition.update!(minor_change: true)

        record.update!(body: new_body)

        puts "Modified body for #{slug}"
      end
    end

    puts unfound_docs

    published_content_containing_advisory_govspeak.each do |edition|
      PublishingApiDocumentRepublishingWorker.new.perform(edition.document.id)
      Whitehall::PublishingApi.republish_document_async(edition.document, bulk: true)
    end
  end

  desc "A dry run rake task to test changes to instances of advisory in govspeak in published editions and HTML attachments into information callouts"
  task dry_run_published_editions: :environment do
    published_content_containing_advisory_govspeak = []

    regex = Regexp.new(/(^@)([\s\S]*?)(@?)(?=(?:^\$CTA|\r?\n\r?\n|^@|$))/m).to_s

    Edition
      .where(state: "published")
      .joins("RIGHT JOIN edition_translations ON edition_translations.edition_id = editions.id")
      .where("body REGEXP ?", regex)
      .find_each do |object|
        published_content_containing_advisory_govspeak << object.content_id
      end

    HtmlAttachment
      .joins(:govspeak_content)
      .where(deleted: false)
      .where.not(attachable: nil)
      .where("govspeak_contents.body REGEXP ?", regex)
      .find_each do |object|
        next unless object.attachable.state == "published"

        published_content_containing_advisory_govspeak << object.content_id
      end

    puts "Found #{published_content_containing_advisory_govspeak.count} published content items with advisory govspeak."
  end
end
