class Document::PaginatedRemarks
  PER_PAGE = 30

  attr_reader :query

  delegate :total_count, to: :query

  def initialize(document, page)
    @document = document
    @query = document.editorial_remarks
                     .includes(:author)
                     .reorder(created_at: :desc, id: :desc)
                     .page(page)
                     .per(PER_PAGE)
  end
end
