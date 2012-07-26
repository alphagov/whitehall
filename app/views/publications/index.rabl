object false
node :count do
  @count
end
node :current_page do
  @page
end
node(:next_page_url, :if => lambda { |_| @next_page }) do
  url_for params.merge(page: @next_page, "_" => nil)
end
node(:prev_page_url, :if => lambda { |_| @page > 1 }) do
  url_for params.merge(page: (@page > 2 ? @page - 1 : nil), "_" => nil)
end
node :results do
  @publications.map { |a| {
      id: a.id,
      title: a.title,
      url: public_document_path(a),
      organisations: a.organisations.map { |o|
        organisation_display_name(o)
      }.to_sentence.html_safe,
      published: render_datetime_microformat(a, :publication_date) {
        a.publication_date.to_s(:long_ordinal)
      }.html_safe,
      publication_type: a.publication_type.singular_name
    }
  }
end
