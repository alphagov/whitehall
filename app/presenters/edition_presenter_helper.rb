module EditionPresenterHelper
  def as_hash
    {
      id: model.id,
      type: model.type.underscore,
      display_type: model.display_type,
      title: model.title,
      url: h.public_document_path(model),
      organisations: model.organisations.map { |o|
        h.organisation_display_name(o)
      }.to_sentence.html_safe,
      display_date_microformat: display_date_microformat,
      public_timestamp: model.public_timestamp
    }
  end

  def link
    h.link_to model.title, h.public_document_path(model)
  end

  def display_organisations
    organisations.map { |o|
      h.organisation_display_name(o) }.to_sentence
  end

  def display_date_microformat
    date_microformat(:public_timestamp)
  end

  def date_microformat(attribute_name)
    h.render_datetime_microformat(model, attribute_name) {
      l(model.send(attribute_name).to_date, format: :long_ordinal)
    }
  end
end
