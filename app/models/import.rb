require 'csv'

class Import < ActiveRecord::Base
  serialize :successful_rows
  has_many :document_sources
  has_many :documents, -> { uniq }, through: :document_sources
  has_many :editions, -> { uniq }, through: :documents
  has_many :import_errors, dependent: :destroy
  has_many :force_publication_attempts, dependent: :destroy
  has_many :import_logs, -> { order :row_number }, dependent: :destroy

  belongs_to :creator, class_name: "User"
  belongs_to :organisation

  TYPES = {
    consultation: [Whitehall::Uploader::ConsultationRow, Consultation],
    news_article: [Whitehall::Uploader::NewsArticleRow, NewsArticle],
    publication: [Whitehall::Uploader::PublicationRow, Publication],
    speech: [Whitehall::Uploader::SpeechRow, Speech],
    statistical_data_set: [Whitehall::Uploader::StatisticalDataSetRow, StatisticalDataSet],
    fatality_notice: [Whitehall::Uploader::FatalityNoticeRow, FatalityNotice],
    detailed_guide: [Whitehall::Uploader::DetailedGuideRow, DetailedGuide],
    case_study: [Whitehall::Uploader::CaseStudyRow, CaseStudy],
  }

  after_destroy :destroy_all_imported_documents

  validate :csv_data_supplied
  validates :organisation_id, presence: true
  validate :valid_csv_data_encoding!
  validates :data_type, inclusion: { in: TYPES.keys.map(&:to_s), message: "%{value} is not a valid type" }
  validate :valid_csv_headings?, if: :valid_csv_data_encoding?
  validate :all_rows_have_old_url?, if: :valid_csv_data_encoding?
  validate :no_duplicate_old_urls, if: :valid_csv_data_encoding?

  def self.excluding_csv_data
    select(Import.columns.map(&:name) - ['csv_data'])
  end

  def self.read_file(file)
    return nil unless file
    raw = file.read.force_encoding("ascii-8bit")
    if raw[0..2] == "\uFEFF".force_encoding("ascii-8bit")
      raw[3..-1]
    else
      raw
    end.force_encoding('utf-8')
  end

  def self.create_from_file(current_user, csv_file, data_type, organisation_id)
    Import.create(
      data_type: data_type,
      organisation_id: organisation_id,
      csv_data: read_file(csv_file),
      creator_id: current_user.id,
      original_filename: csv_file && csv_file.original_filename,
      successful_rows: []
    )
  end

  def enqueue!
    update_column(:import_enqueued_at, Time.zone.now)
    ImportWorker.perform_async(self.id)
  end

  def status
    if import_enqueued_at.nil?
      :new
    elsif import_started_at.nil?
      :queued
    elsif import_finished_at.nil?
      :running
    else
      :finished
    end
  end

  def row_numbers
    (2..rows.count).to_a
  end

  def successful_row_numbers
    document_sources.pluck(:row_number)
  end

  def failed_row_numbers
    import_errors.pluck(:row_number)
  end

  def missing_row_numbers
    @missing_row_numbers ||= row_numbers - successful_row_numbers - failed_row_numbers
  end

  def success_count
    status == :finished ? documents.count(distinct: true) : 0
  end

  def most_recent_force_publication_attempt
    force_publication_attempts.last
  end

  def force_publishable?
    reason_for_not_being_force_publishable.nil?
  end

  def reason_for_not_being_force_publishable
    case status
    when :finished
      most_recent = most_recent_force_publication_attempt
      if most_recent.nil? || (most_recent.present?) && most_recent.repeatable?
        if imported_editions.empty?
          'Import created no documents'
        elsif imported_editions.imported.any?
          'Some still imported'
        elsif force_publishable_editions.empty?
          'None to publish'
        else
          nil
        end
      else
        'Attempt to force publish is already in progress'
      end
    when :new, :queued, :running
      'Import still running'
    else
      'Import failed'
    end
  end

  def force_publish!
    force_publication_attempts.create!.enqueue!
  end

  def force_publishable_editions
    imported_editions.where(state: ['draft', 'submitted'])
  end

  # needed because count does not resepect uniq until rails 3.2.13
  def force_publishable_edition_count
    force_publishable_editions.count(distinct: true)
  end

  def imported_editions
    is_first_edition_for_document = "NOT EXISTS (
        SELECT 1
          FROM editions e2
         WHERE e2.document_id = editions.document_id
           AND e2.id < editions.id)"
    editions.where(is_first_edition_for_document)
  end

  def import_errors_for_row(row_number)
    import_errors.where(row_number: row_number).map do |import_error|
      import_error.message
    end
  end

  def number_of_rows_with_errors
    import_errors.count(:row_number, distinct: true)
  end

  def perform(options = {})
    progress_logger.start(rows)
    rows.each_with_index do |data_row, ix|
      row_number = ix + 2
      if blank_row?(data_row)
        progress_logger.info("blank, skipped", row_number)
        next
      end
      ImportRowWorker.perform_async(id, data_row.to_hash, row_number)
    end

    progress_logger.finish
  end

  def progress_logger
    @progress_logger ||= Whitehall::Uploader::ProgressLogger.new(self)
  end

  def log
    import_logs.map(&:to_s).join("\n")
  end

  def import_user
    User.find_by_name!("Automatic Data Importer")
  end

  def headers
    rows.headers
  end

  NilAsBlankConverter = ->(heading) { heading || "" }

  def rows
    @rows ||= CSV.parse(csv_data, headers: true, header_converters: [NilAsBlankConverter, :downcase])
  end

  def blank_row?(row)
    row.fields.all?(&:blank?)
  end

  def row_class
    data_type && TYPES[data_type.to_sym] && TYPES[data_type.to_sym][0]
  end

  def model_class
    data_type && TYPES[data_type.to_sym] && TYPES[data_type.to_sym][1]
  end

  # We cannot use the standard presence validator as sometimes
  # broken data cannot have string methods called on it
  def csv_data_supplied
    errors.add(:csv_data, "not supplied") if csv_data.nil?
  end

  def valid_csv_data_encoding!
    if (csv_data)
      errors.add(:csv_data, "Invalid #{csv_data.encoding} character encoding") unless valid_csv_data_encoding?
    end
  end

  def valid_csv_data_encoding?
    csv_data && csv_data.valid_encoding?
  end

  def valid_csv_headings?
    return unless row_class && csv_data
    heading_validation_errors = row_class.heading_validation_errors(headers)
    heading_validation_errors.each do |e|
      errors.add(:csv_data, e)
    end
  end

  def all_rows_have_old_url?
    if blank_row_number = rows.find_index { |row| row.fields.any?(&:present?) && row['old_url'].blank? }
      errors.add(:csv_data, "Row #{blank_row_number + 2}: old_url is blank")
    end
  end

  def no_duplicate_old_urls
    urls = rows.map.with_index { |row, i| [i + 2, row['old_url']] }
    duplicates = urls.group_by { |row_number, old_url| old_url }.select { |old_url, set| set.size > 1 }
    if duplicates.any?
      duplicates.each do |old_url, set|
        errors.add(:csv_data, "Duplicate old_url '#{old_url}' in rows #{set.map {|r| r[0]}.join(', ')}")
      end
    end
  end

  def self.use_separate_connection
    # ActiveRecord stashes DB connections on a class
    # hierarchy basis, so this establishes a separate
    # DB connection for just the Import model that
    # will be free from transactional semantics
    # applied to ActiveRecord::Base.

    # This is so we can log information as we process
    # files without worrying about transactional
    # rollbacks for the actual import process.
    Import.establish_connection ActiveRecord::Base.configurations[Rails.env]
    ImportError.establish_connection ActiveRecord::Base.configurations[Rails.env]
    ImportLog.establish_connection ActiveRecord::Base.configurations[Rails.env]
  end

  private

  def destroy_all_imported_documents
    Document.destroy_all(id: self.document_ids)
  end

end
