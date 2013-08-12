json.results_any? @filter.editions.any?
json.set! :results do
  json.array! @filter.editions do |edition|
    json.extract!     edition, :id, :document_id, :title, :display_type
    json.type         edition.type.underscore
    json.url          admin_edition_path(edition)
    json.public_time  render_datetime_microformat(edition, :public_timestamp) { edition.public_timestamp.to_date.to_s(:long_ordinal) }
    json.organisation edition.organisations.map { |o| organisation_display_name(o) }.to_sentence.html_safe
  end
end
