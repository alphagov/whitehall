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
    csv << (['Organisation'] + months.size.times.map { |_| %w{Published Updates} }.flatten)

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
end
