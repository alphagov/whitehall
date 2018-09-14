require 'ruby-progressbar'

namespace :reporting do
  def opts_from_environment(*option_keys)
    {}.tap do |option_hash|
      option_keys.each do |key|
        option_hash[key] = ENV[key.to_s.upcase] if ENV[key.to_s.upcase]
      end
    end
  end

  desc "An overview of attachment statistics by organisation as CSV"
  task attachments_overview: :environment do
    AttachmentDataReporter.new(opts_from_environment(:data_path, :start_date, :end_date)).overview
  end

  desc "A report of attachments statistics with related document slugs as CSV"
  task attachments_report: :environment do
    AttachmentDataReporter.new(opts_from_environment(:data_path, :start_date, :end_date)).report
  end

  desc "A report of attachment uploads with related document title and path"
  task attachment_upload_report: :environment do
    AttachmentDataReporter.new(opts_from_environment(:data_path, :start_date, :end_date)).attachment_upload_report
  end

  desc "A report of collection statistics by organisation as CSV"
  task collections_report: :environment do
    CollectionDataReporter.new(ENV.fetch('OUTPUT_DIR', './tmp')).report
  end

  desc "A report of PDF attachments counts by organisation as CSV. Takes many hours to run."
  task pdf_attachments_report: :environment do
    PDFAttachmentReporter.new(opts_from_environment(:data_path, :first_period_start_date, :last_time_period_days)).pdfs_by_organisation
  end

  desc "A CSV report of organisation Edition publishing by month. Splits by freshly created and updated content"
  task organisation_publishing_by_month: :environment do
    options = opts_from_environment(:start_date, :end_date)

    date_range = Date.parse(options[:start_date])...Date.parse(options[:end_date])
    months = date_range.select { |d| d.day == 1 }.map { |m| "#{m.year}-#{m.month.to_s.rjust(2, '0')}" }

    csv = CSV.open("organisation_publishing_by_month-#{options[:start_date]}-#{options[:end_date]}.csv", 'w')
    csv << ([''] + months.map { |m| [m, m] }.flatten)
    csv << (%w[Organisation] + months.size.times.map { |_| %w{Published Updates} }.flatten)

    first_editions = Edition.
      order(:id).
      group(:document_id).
      pluck(:id).to_set

    # So we have the organisation association for all edition types
    Edition.include(Edition::Organisations)

    EditionRecord = Struct.new(:id, :updated_at, :name)

    all_editions = Edition.
      joins(organisations: :translations).
      where(
        updated_at: date_range,
        edition_organisations: { lead: 1 },
        state: %w{published superseded},
        organisation_translations: { locale: 'en' }
      ).
      pluck(*EditionRecord.members).
      map { |r| EditionRecord.new(*r).tap { |er| er.name.strip! } } # One organisation has a leading space

    by_org = all_editions.group_by(&:name).sort

    by_org.each do |(org, records)|
      row = [org]
      by_month = records.group_by { |r| "#{r.updated_at.year}-#{r.updated_at.month.to_s.rjust(2, '0')}" }

      months.each do |month|
        created, updated = (by_month[month] || []).partition { |r| first_editions.include?(r.id) }
        row += [created.size, updated.size]
      end
      csv << row
    end
  end

  desc "A CSV report of all documents published by the given organisation"
  task organisation_documents: :environment do
    options = opts_from_environment(:organisation_slug)

    CSV.open("#{options[:organisation_slug]}-documents.csv", 'w') do |csv|
      csv << ['Content ID', 'Path', 'Title', 'Format', 'First Published', 'Last Updated']

      # So we have the organisation association for all edition types
      Edition.include(Edition::Organisations)

      org_id = Organisation.where(slug: options[:organisation_slug]).limit(1).pluck(:id).first

      scope = Edition.
        distinct(:document_id).
        joins(:edition_organisations, :document, :translations).
        includes(:document, :translations).
        where(
          edition_organisations: { lead: 1, organisation_id: org_id },
          state: %w{published}
        )

      progress_bar = ProgressBar.create(format: "%e [%b>%i] [%c/%C]", total: scope.count)

      scope.find_each do |edition|
        first_published = edition.document.ever_published_editions.order(:id).limit(1).pluck(:public_timestamp).first
        csv << [
          edition.content_id,
          edition.search_link,
          edition.title,
          edition.class.name.underscore.humanize,
          first_published.iso8601,
          edition.public_timestamp.iso8601
        ]
        progress_bar.increment
      end
    end
  end

  namespace :consultations do
    task all: :environment do
      options = opts_from_environment(:start_date, :data_path)
      ConsultationReporter.new(options).all_consultations
    end
  end
end
