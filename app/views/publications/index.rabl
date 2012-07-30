object false
node :count do
  @publications.count
end
node :current_page do
  @publications.current_page
end
node :next_page, unless: lambda { |_| @publications.last_page? } do
  @publications.current_page + 1
end
node :prev_page, unless: lambda { |_| @publications.first_page? } do
  @publications.current_page - 1
end
node :total_pages do
  @publications.num_pages
end
node(:next_page_url, unless: lambda { |_| @publications.last_page? }) do
  url_for params.merge(page: (@publications.current_page + 1), "_" => nil)
end
node(:prev_page_url, unless: lambda { |_| @publications.first_page? }) do
  url_for params.merge(page: (@publications.current_page - 1), "_" => nil)
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
