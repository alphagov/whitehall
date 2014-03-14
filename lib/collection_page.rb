class CollectionPage < Array
  attr_reader :total, :per_page, :page

  def initialize(collection_subset, total: nil, page: nil, per_page: nil)
    super(collection_subset)
    @total = total
    @per_page = per_page
    @page = page
  end

  def number_of_pages
    (total.to_f / per_page).ceil
  end

  def next_page?
    (page + 1) <= number_of_pages
  end

  def previous_page?
    (page - 1) >= 1
  end
end
