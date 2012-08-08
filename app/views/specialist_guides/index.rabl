object false
node :count do
  @filter.documents.count
end
node :current_page do
  @filter.documents.current_page
end
node :next_page, unless: lambda { |_| @filter.documents.last_page? } do
  @filter.documents.current_page + 1
end
node :prev_page, unless: lambda { |_| @filter.documents.first_page? } do
  @filter.documents.current_page - 1
end
node :total_pages do
  @filter.documents.num_pages
end
node(:next_page_url, unless: lambda { |_| @filter.documents.last_page? }) do
  url_for params.merge(page: (@filter.documents.current_page + 1), "_" => nil)
end
node(:prev_page_url, unless: lambda { |_| @filter.documents.first_page? }) do
  url_for params.merge(page: (@filter.documents.current_page - 1), "_" => nil)
end
node :results do
  @filter.documents.map { |a| {
      id: a.id,
      type: "specialist_guide",
      title: a.title,
      url: public_document_path(a),
      organisations: a.organisations.map { |o|
        organisation_display_name(o)
      }.to_sentence.html_safe,
      topics: a.topics.map(&:name).join(", ").html_safe
    }
  }
end
