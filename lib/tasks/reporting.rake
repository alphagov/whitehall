require "ruby-progressbar"

namespace :reporting do
  desc "A CSV report of the number of publications in draft state by organisation between the dates specified [Month Day Year 00:00:00]"
  task :number_of_draft_publications_by_organisation_by_date_range, %i[start_date end_date] => :environment do |_t, args|
    raise "Missing start_date or end_date" unless args[:start_date].present? && args[:end_date].present?

    Reports::DraftPublicationsReport.new(args[:start_date], args[:end_date]).report
  end

  desc "A CSV report of non-accessible attachments uploads published by the given organisation"
  task :organisation_attachments_report, %i[organisation_slug] => :environment do |_t, args|
    raise "Missing organisation slug" if args[:organisation_slug].blank?

    Reports::OrganisationAttachmentsReport.new(args[:organisation_slug]).report
  end

  desc "A CSV report of non-HTML attachments uploads published by all organisations"
  task published_attachments_report: :environment do
    Reports::PublishedAttachmentsReport.new.report
  end
end
