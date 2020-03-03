class Whitehall::Exporters::DocumentsInfoExporter
  attr_reader :document_ids

  def initialize(document_ids)
    @document_ids = document_ids
  end

  def call
    document_ids.map do |doc_id|
      document = Document.find(doc_id)
      {
        document_id: doc_id,
        document_information: {
          locales: locales_hash[doc_id],
          content_id: document.content_id
        },
      }
    end
  end

private

  def locales_hash
    @locales_hash ||= Edition
      .joins(:translations)
      .where(document_id: document_ids)
      .group(:document_id)
      .pluck(:document_id, "GROUP_CONCAT(DISTINCT(edition_translations.locale))")
      .each_with_object({}) { |(k, v), memo| memo[k] = v.split(",") }
  end
end
