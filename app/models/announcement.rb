class Announcement
  def self.by_first_published_at(announcements)
    announcements.sort_by(&:first_published_at).reverse
  end

  def self.published_as(slug)
    document = Document.at_slug(document_types, slug)
    document && document.published_edition
  end

  def self.document_types
    [NewsArticle.document_type, Speech.document_type]
  end
end
