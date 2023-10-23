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

  desc "Prints a list of content IDs that documents whose live edition contains a given regular expression"
  task :matching_docs, [:regex] => :environment do |_, args|
    regex = Regexp.new(/#{args[:regex]}/)

    Document.where.not(live_edition_id: nil).find_in_batches(batch_size: 1000) do |batch|
      batch.each do |document|
        next unless document.editions.published.any?

        puts document.content_id if regex.match?(document.editions.published.last.body)
      end
    end
  end
end
