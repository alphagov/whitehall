module EditionPresenterHelper
  def link
    h.link_to model.title, public_document_path(model)
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
