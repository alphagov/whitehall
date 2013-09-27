class ImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  def perform(id, options={})
    Import.use_separate_connection
    @import = Import.find(id)
    @import.perform(options)
  end
end
