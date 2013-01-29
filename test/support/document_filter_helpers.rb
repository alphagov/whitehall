module DocumentFilterHelpers
  def with_number_of_documents_per_page(count)
    original_count = Whitehall::DocumentFilter::Mysql.number_of_documents_per_page
    Whitehall::DocumentFilter::Mysql.number_of_documents_per_page = count
    yield
  ensure
    Whitehall::DocumentFilter::Mysql.number_of_documents_per_page = original_count
  end
end
