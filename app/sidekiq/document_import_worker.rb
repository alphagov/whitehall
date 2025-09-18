require_relative "./worker_base"
require_relative "../../lib/whitehall/document_importer"

class DocumentImportWorker < WorkerBase
  def perform(path_to_import_file)
    data = JSON.parse(File.read(path_to_import_file))

    # Automatically roll back the import if we encounter any errors
    ApplicationRecord.transaction do
      Rails.logger = Logger.new($stdout)
      Rails.logger.level = Logger::INFO
      Rails.logger.info "Importing document #{path_to_import_file} into Whitehall..."
      document = Whitehall::DocumentImporter.import!(data)
      Rails.logger.info "...document imported (/government/admin/standard-editions/#{document.live_edition.id})"

      Rails.logger.info "Re-claiming the route (from Content Publisher) in Publishing API..."
      Services.publishing_api.put_path(
        document.live_edition.base_path,
        {
          publishing_app: "whitehall",
          override_existing: true,
        },
      )
      Rails.logger.info "...route claimed."

      Rails.logger.info "Re-presenting document to Publishing API..."
      PublishingApiDocumentRepublishingWorker.new.perform(document.id)
      Rails.logger.info "...document re-presented."
    end
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.info("Skipping #{path_to_import_file} (already imported)")
  rescue JSON::ParserError
    raise "Failed to parse JSON for #{path_to_import_file}"
  end
end
