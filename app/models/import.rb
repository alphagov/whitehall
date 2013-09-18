require 'csv'

class Import < ActiveRecord::Base
  serialize :successful_rows
  has_many :document_sources
  has_many :documents, through: :document_sources, uniq: true
  has_many :editions, through: :documents, uniq: true
  has_many :import_errors, dependent: :destroy
  has_many :force_publication_attempts, dependent: :destroy
  has_many :import_logs, dependent: :destroy

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
    Delayed::Job.enqueue(Job.new(self.id))
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
    attachment_cache = options[:attachment_cache] || Whitehall::Uploader::AttachmentCache.new(Whitehall::Uploader::AttachmentCache.default_root_directory, progress_logger)

    progress_logger.start(rows)
    rows.each_with_index do |data_row, ix|
      row_number = ix + 2
      progress_logger.at_row(row_number) do
        if blank_row?(data_row)
          progress_logger.info("blank, skipped")
          next
        end
        row = row_class.new(data_row.to_hash, row_number, attachment_cache, organisation, progress_logger)
        document_sources = DocumentSource.where(url: row.legacy_urls)
        if document_sources.any?
          document_sources.each do |document_source|
            progress_logger.already_imported(document_source)
          end
        else
          Edition::AuditTrail.acting_as(import_user) do
            import_row(row, row_number, import_user, progress_logger)
          end
        end
      end
    end

    progress_logger.finish
  end

  def progress_logger
    @progress_logger ||= ProgressLogger.new(self)
  end

  def log
    import_logs.map(&:to_s).join("\n")
  end

  def import_user
    User.find_by_name!("Automatic Data Importer")
  end

  def import_row(row, row_number, creator, progress_logger)
    progress_logger.transaction do
      attributes = row.attributes.merge(creator: creator, state: 'imported')
      model = model_class.new(attributes)
      if model.save
        save_translation!(model, row, row_number) if row.translation_present?
        assign_document_series!(model, row.document_series)
        row.legacy_urls.each do |legacy_url|
          DocumentSource.create!(document: model.document, url: legacy_url, import: self, row_number: row_number)
        end
        progress_logger.success(model)
      else
        record_errors_for(model)
      end
    end
  end
  handle_asynchronously :import_row

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

  def record_errors_for(model, translated=false)
    error_prefix = translated ? 'Translated ' : ''

    model.errors.keys.each do |attribute|
      next if [:attachments, :images].include?(attribute)
      progress_logger.error("#{error_prefix}#{attribute}: #{model.errors[attribute].join(", ")}")
    end
    if model.respond_to?(:attachments)
      model.attachments.reject(&:valid?).each do |a|
        progress_logger.error("#{error_prefix}Attachment '#{a.attachment_source.url}': #{a.errors.full_messages.to_s}")
      end
    end
    if model.respond_to?(:images)
      model.images.reject(&:valid?).each do |i|
        progress_logger.error("#{error_prefix}Image '#{i.caption}': #{i.errors.full_messages.to_s}")
      end
    end
  end

  def save_translation!(model, row, row_number)
    translation = LocalisedModel.new(model, row.translation_locale)

    if translation.update_attributes(row.translation_attributes)
      if locale = Locale.find_by_code(row.translation_locale.to_s)
        DocumentSource.create!(document: model.document, url: row.translation_url, locale: locale.code, import: self, row_number: row_number)
      else
        progress_logger.error("Locale not recognised")
      end
    else
      record_errors_for(translation, true)
    end
  end

  def assign_document_series!(model, document_series)
    if document_series.any?
      groups = document_series.map do |series|
        series.groups.first_or_initialize(DocumentSeriesGroup.default_attributes)
      end
      model.document.document_series_groups << groups
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

  class ProgressLogger
    def initialize(import)
      @import = import
      @current_row = nil
      @errors_during = []
    end

    def at_row(row_number, &block)
      @current_row = row_number
      yield
      @current_row = nil
    end

    def transaction(&block)
      ActiveRecord::Base.transaction do
        begin
          @errors_during = []
          yield
        rescue => e
          self.error(e.to_s + "\n" + e.backtrace.join("\n"))
        end
        raise ActiveRecord::Rollback if @errors_during.any?
      end
    end

    def start(rows)
      @import.update_column(:total_rows, rows.size)
      @import.update_column(:import_started_at, Time.zone.now)
    end

    def finish
      @import.update_column(:import_finished_at, Time.zone.now)
    end

    def info(message)
      write_log(:info, message)
    end

    def warn(message)
      write_log(:warning, message)
    end

    def error(error_message)
      @errors_during << @import.import_errors.create!(row_number: @current_row, message: error_message)
    end

    def success(model_object)
      @import.update_column(:current_row, @current_row)
    end

    def already_imported(document_source)
      error("#{document_source.url} already imported by import '#{document_source.import_id}' row '#{document_source.row_number}'")
    end

    def write_log(level, data)
      @import.import_logs.create(row_number: @current_row, level: level, message: data)
    end
  end

  class Job < Struct.new(:id)
    def perform(options = {})
      import.perform options
    end

    def error(delayed_job, error)
      import.progress_logger.error(error.to_s + error.backtrace.join("\n"))
    end

  private
    def import
      @import ||= begin
                    Import.use_separate_connection
                    Import.find(self.id)
                  end
    end
  end

  private
  def destroy_all_imported_documents
    Document.destroy_all(id: self.document_ids)
  end

end
