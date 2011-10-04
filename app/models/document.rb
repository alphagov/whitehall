class Document < ActiveRecord::Base
  has_many :editions

  def self.published
    where %{
      EXISTS (
        SELECT 1 FROM editions AS published_editions
        WHERE published_editions.document_id = documents.id
        AND published_editions.state = 'published'
      )
    }
  end

  def published_edition
    editions.published.first
  end
end