class Whitehall::Exporters::DocumentsInfoExporter
  attr_reader :document_ids

  def initialize(document_ids)
    @document_ids = document_ids
  end

  def call
    document_ids.map do |doc_id|
      {
        document_id: doc_id,
        document_information: {
          locales: locales_hash[doc_id],
          subtypes: subtypes_hash[doc_id],
          lead_organisations: lead_orgs_for_latest_edition_hash[doc_id],
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

  def subtypes_hash
    @subtypes_hash ||= subtypes_query.each_with_object({}) do |(document_id, news, speeches, publications, corporate), memo|
      news_article_types = news.to_s.split(",").map { |id| NewsArticleType.find_by_id(id.to_i)&.key }
      speech_types = speeches.to_s.split(",").map { |id| SpeechType.find_by_id(id.to_i)&.key }
      publications_types = publications.to_s.split(",").map { |id| PublicationType.find_by_id(id.to_i)&.key }
      corporate_types = corporate.to_s.split(",").map { |id| CorporateInformationPageType.find_by_id(id.to_i)&.key }
      memo[document_id] = [news_article_types, speech_types, publications_types, corporate_types].flatten
    end
  end

  def lead_orgs_for_latest_edition_hash
    @lead_orgs_for_latest_edition_hash ||= Edition
      .joins("INNER JOIN edition_organisations eo ON eo.edition_id = editions.id")
      .joins("INNER JOIN organisations o ON o.id = eo.organisation_id")
      .latest_edition
      .where(document_id: document_ids)
      .where(eo: { lead: true })
      .group(:document_id)
      .pluck(:document_id, "GROUP_CONCAT(DISTINCT(o.content_id))")
      .each_with_object({}) { |(k, v), memo| memo[k] = v.split(",") }
  end

  def subtypes_query
    Edition
      .where(document_id: document_ids)
      .group(:document_id)
      .pluck(:document_id,
             "GROUP_CONCAT(DISTINCT(editions.news_article_type_id))",
             "GROUP_CONCAT(DISTINCT(editions.speech_type_id))",
             "GROUP_CONCAT(DISTINCT(editions.publication_type_id))",
             "GROUP_CONCAT(DISTINCT(editions.corporate_information_page_type_id))")
  end
end
