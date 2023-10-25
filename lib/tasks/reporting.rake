require "ruby-progressbar"

namespace :reporting do
  desc "A CSV report of non-accessible attachments uploads published by the given organisation"
  task :organisation_attachments_report, %i[organisation_slug] => :environment do |_t, args|
    raise "Missing organisation slug" if args[:organisation_slug].blank?

    Reports::OrganisationAttachmentsReport.new(args[:organisation_slug]).report
  end

  desc "A CSV report of non-HTML attachments uploads published by all organisations"
  task published_attachments_report: :environment do
    Reports::PublishedAttachmentsReport.new.report
  end

  desc "Prints a list of content IDs for documents whose govspeak content contains a given regular expression"
  task :matching_docs, [:regex] => :environment do |_, args|
    regex = Regexp.new(/#{args[:regex]}/)

    Document.where.not(live_edition_id: nil).find_each do |object|
      next unless object.editions.published.any?

      document_includes_regex(regex, object.content_id, object.class.name, object.editions.published.last.body)
    end

    HtmlAttachment.find_each do |object|
      next unless object.govspeak_content

      document_includes_regex(regex, object.content_id, object.class.name, object.govspeak_content.body)
    end

    Person.find_each do |object|
      document_includes_regex(regex, object.content_id, object.class.name, object.biography)
    end

    PolicyGroup.find_each do |object|
      document_includes_regex(regex, object.content_id, object.class.name, object.description)
    end

    WorldLocationNews.find_each do |object|
      document_includes_regex(regex, object.content_id, object.class.name, object.mission_statement)
    end

    WorldwideOffice.find_each do |object|
      document_includes_regex(regex, object.content_id, object.class.name, object.access_and_opening_times)
    end
  end
end

def document_includes_regex(regex, content_id, class_name, text)
  puts "#{class_name}: #{content_id}" if text && text.match?(regex)
end
