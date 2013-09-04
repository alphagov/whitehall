json.results_any? @filter.editions.any?
json.set! :results do
  json.array! @filter.editions do |edition|
    json.extract!     edition, :id, :document_id, :title, :display_type
    json.type         edition.type.underscore
    json.url          admin_edition_path(edition)
    json.public_time  public_time_for_edition(edition)
    json.organisation edition.organisations.map { |o| organisation_display_name(o) }.to_sentence.html_safe
  end
end
