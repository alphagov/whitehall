class ImportRowWorker < Struct.new(:import_id, :row_hash, :row_number)
  include Sidekiq::Worker
  sidekiq_options queue: :imports

  def perform(*args)
    ImportRowWorker.new(*args).run
  end

  def run
    document_sources = DocumentSource.where(url: row.legacy_urls)
    if document_sources.any?
      document_sources.each do |document_source|
        progress_logger.already_imported(document_source, row_number)
      end
    else
      Edition::AuditTrail.acting_as(import_user) do
        import_row!
      end
    end
  end

protected

  def import_row!
    progress_logger.with_transaction(row_number) do
      attributes = row.attributes.merge(creator: import_user, state: 'imported')
      model = import.model_class.new(attributes)
      if model.save
        save_translation!(model, row) if row.translation_present?
        assign_document_collections!(model, row.document_collections)
        row.legacy_urls.each do |legacy_url|
          DocumentSource.create!(document: model.document, url: legacy_url, import: import, row_number: row_number)
        end
      else
        record_errors_for(model, row_number)
      end
    end
  end

  def save_translation!(model, row)
    translation = LocalisedModel.new(model, row.translation_locale)

    if translation.update_attributes(row.translation_attributes)
      if locale = Locale.find_by_code(row.translation_locale.to_s)
        DocumentSource.create!(document: model.document, url: row.translation_url, locale: locale.code, import: import, row_number: row.line_number)
      else
        progress_logger.error("Locale not recognised", row.line_number)
      end
    else
      record_errors_for(translation, row.line_number, true)
    end
  end

  def assign_document_collections!(model, document_collections)
    if document_collections.any?
      groups = document_collections.map do |collection|
        collection.groups.first_or_initialize(DocumentCollectionGroup.default_attributes)
      end
      model.document.document_collection_groups << groups
    end
  end

  def record_errors_for(model, row_number, translated=false)
    error_prefix = translated ? 'Translated ' : ''

    model.errors.keys.each do |attribute|
      next if [:attachments, :images].include?(attribute)
      progress_logger.error("#{error_prefix}#{attribute}: #{model.errors[attribute].join(", ")}", row_number)
    end
    if model.respond_to?(:attachments)
      model.attachments.reject(&:valid?).each do |a|
        progress_logger.error("#{error_prefix}Attachment '#{a.attachment_source.url}': #{a.errors.full_messages.to_s}", row_number)
      end
    end
    if model.respond_to?(:images)
      model.images.reject(&:valid?).each do |i|
        progress_logger.error("#{error_prefix}Image '#{i.caption}': #{i.errors.full_messages.to_s}", row_number)
      end
    end
  end

  def import
    @import ||= Import.excluding_csv_data.find(import_id)
  end

  def import_user
    @import_user ||= import.import_user
  end

  def organisation
    @organisation ||= import.organisation
  end

  def row
    @row ||= import.row_class.new(row_hash, row_number, attachment_cache, organisation, progress_logger)
  end

  def attachment_cache
    @attachment_cache ||= Whitehall::Uploader::AttachmentCache.new(Whitehall::Uploader::AttachmentCache.default_root_directory, progress_logger)
  end

  def progress_logger
    @progress_logger ||= Whitehall::Uploader::ProgressLogger.new(import)
  end
end
