require 'csv'

class Import < ActiveRecord::Base
  serialize :already_imported
  serialize :successful_rows
  has_many :document_sources
  has_many :import_errors, dependent: :destroy

  belongs_to :creator, class_name: "User"
  belongs_to :organisation

  TYPES = {
    consultation: [Whitehall::Uploader::ConsultationRow, Consultation],
    news_article: [Whitehall::Uploader::NewsArticleRow, NewsArticle],
    publication: [Whitehall::Uploader::PublicationRow, Publication],
    speech: [Whitehall::Uploader::SpeechRow, Speech],
    statistical_data_set: [Whitehall::Uploader::StatisticalDataSetRow, StatisticalDataSet],
    fatality_notice: [Whitehall::Uploader::FatalityNoticeRow, FatalityNotice]
  }

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
      already_imported: [],
      successful_rows: [],
      log: ""
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
    elsif import_errors.any?
      :failed
    else
      :succeeded
    end
  end

  def import_errors_for_row(row_number)
    import_errors.where(row_number: row_number).map do |import_error|
      import_error.message
    end
  end

  def number_of_rows_with_errors
    import_errors.count(:row_number, distinct: true)
  end

  def acting_as(user)
    original_user = PaperTrail.whodunnit
    PaperTrail.whodunnit = user
    yield
  ensure
    PaperTrail.whodunnit = original_user
  end

  def perform(options = {})
    attachment_cache = options[:attachment_cache] || Whitehall::Uploader::AttachmentCache.new(Whitehall::Uploader::AttachmentCache.default_root_directory, progress_logger)

    progress_logger.start(rows)
    ActiveRecord::Base.transaction do
      rows.each_with_index do |data_row, ix|
        row_number = ix + 2
        progress_logger.at_row(row_number) do
          if blank_row?(data_row)
            progress_logger.info("blank, skipped")
            next
          end
          row = row_class.new(data_row.to_hash, row_number, attachment_cache, organisation, progress_logger)
          if document_source = DocumentSource.find_by_url(row.legacy_url)
            progress_logger.already_imported(row.legacy_url, document_source)
          else
            acting_as(automatic_data_importer) do
              import_row(row, row_number, automatic_data_importer, progress_logger)
            end
          end
        end
      end
      raise ActiveRecord::Rollback if import_errors.any?
    end

    progress_logger.finish
  end

  def progress_logger
    @progress_logger ||= ProgressLogger.new(self)
  end

  def automatic_data_importer
    User.find_by_name!("Automatic Data Importer")
  end

  def import_row(row, row_number, creator, progress_logger)
    attributes = row.attributes.merge(creator: creator, state: 'imported')
    model = model_class.new(attributes)
    if model.save
      ds = DocumentSource.create!(document: model.document, url: row.legacy_url, import: self, row_number: row_number)
      progress_logger.success(model)
      true
    else
      model.errors.keys.each do |attribute|
        next if [:attachments, :images].include?(attribute)
        progress_logger.error("#{attribute}: #{model.errors[attribute].join(", ")}")
      end
      if model.respond_to?(:attachments)
        model.attachments.reject(&:valid?).each do |a|
          progress_logger.error("Attachment '#{a.attachment_source.url}': #{a.errors.full_messages.to_s}")
        end
      end
      if model.respond_to?(:images)
        model.images.reject(&:valid?).each do |i|
          progress_logger.error("Image '#{i.caption}': #{i.errors.full_messages.to_s}")
        end
      end

      false
    end
  rescue => e
    progress_logger.error(e.to_s + "\n" + e.backtrace.join("\n"))
    false
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
    Import.establish_connection Rails.configuration.database_configuration[Rails.env]
    ImportError.establish_connection Rails.configuration.database_configuration[Rails.env]
  end

  class ProgressLogger
    def initialize(import)
      @import = import
      @current_row = nil
    end

    def at_row(row_number, &block)
      @current_row = row_number
      yield
      @current_row = nil
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
      @import.import_errors.create!(row_number: @current_row, message: error_message)
    end

    def success(model_object)
      @import.update_column(:current_row, @current_row)
    end

    def already_imported(url, document_source)
      error("#{url} already imported by import '#{document_source.import_id}' row '#{document_source.row_number}'")
    end

    def write_log(level, data)
      log = @import.log || ""
      log << "Row #{@current_row || '-'} - #{level}: #{data}\n"
      @import.update_column(:log, log)
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
end
