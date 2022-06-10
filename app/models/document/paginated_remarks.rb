# not sure this actually needs a class, done quickly for consistency with PaginatedHistory
class Document::PaginatedRemarks
  attr_reader :document, :query
  delegate :total_count, to: :query

  def initialize(document, page)
    @document = document
    @query = document.editorial_remarks
                     .includes(:author)
                     .order(created_at: :desc, id: :desc)
                     .page(page)
                     .per(30)
  end

  def entries
    query.to_a
  end
end

