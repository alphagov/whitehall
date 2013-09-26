class ImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  def perform(id, options={})
    import(id)
    @import.perform options
  end

  def error(job, error)
    @import.progress_logger.error(error.to_s + error.backtrace.join("\n"), nil)
  end

  private

  def import(id)
    @import ||= begin
                  Import.use_separate_connection
                  Import.find(id)
                end
  end

end
