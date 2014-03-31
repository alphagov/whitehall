class ForcePublicationAttempt < ActiveRecord::Base
  belongs_to :import

  def enqueue!
    update_column(:enqueued_at, Time.zone.now)
    ImportForcePublicationAttemptWorker.perform_async(self.id)
  end

  def documents
    import.force_publishable_editions
  end

  def document_count
    import.force_publishable_edition_count
  end

  def perform(options = {})
    progress_logger.start(document_count)

    worker = ForcePublisher::Worker.new
    worker.force_publish!(documents, progress_logger)

    progress_logger.finish
  end

  def successes
    @successes ||= []
  end

  def failed_documents
    self.total_documents - self.successful_documents
  end

  def status
    if enqueued_at.nil?
      :new
    elsif started_at.nil?
      :queued
    elsif finished_at.nil?
      :running
    elsif total_documents == successful_documents
      :success
    else
      :failures
    end
  end

  def status_timestamp_method
    case status
    when :new
      :created_at
    when :queued
      :enqueued_at
    when :running
      :started_at
    else
      :finished_at
    end
  end

  def status_timestamp
    __send__(status_timestamp_method)
  end

  def repeatable?
    [:success, :failures].include?(self.status)
  end

  def progress_logger
    @progress_logger ||= ProgressLogger.new(self)
  end

  class ProgressLogger
    include Admin::EditionRoutesHelper

    def initialize(force_publish_attempt)
      @force_publish_attempt = force_publish_attempt
      @current_row = nil
    end

    def start(document_count)
      @force_publish_attempt.update_column(:total_documents, document_count)
      @force_publish_attempt.update_column(:started_at, Time.zone.now)
      write_log(:info, "Started run: #{@force_publish_attempt.started_at}")
    end

    def finish
      @force_publish_attempt.update_column(:successful_documents, @force_publish_attempt.successes.size)
      @force_publish_attempt.update_column(:finished_at, Time.zone.now)
      write_log(:info, "Finished run: #{@force_publish_attempt.finished_at}")
    end

    def failure(document, error_message)
      write_log(:error, "#{document.nil? ? 'nil' : document.id}: #{error_message.to_s}")
    end

    def success(document)
      write_log(:success, "#{document.id}: https://www.gov.uk#{Whitehall.url_maker.public_document_path(document)}")
      @force_publish_attempt.successes << document
    end

    def write_log(level, data)
      log = @force_publish_attempt.log || ""
      log << "#{level}: #{data}\n"
      @force_publish_attempt.update_column(:log, log)
    end
  end

  class Job < Struct.new(:id)
    def perform(options = {})
      force_publish_attempt.perform options
    end

    def error(delayed_job, error)
      force_publish_attempt.progress_logger.write_log(:error, error.to_s + error.backtrace.join("\n"))
    end

    def force_publish_attempt
      @force_publish_attempt ||= ForcePublicationAttempt.find(self.id)
    end
  end
end
