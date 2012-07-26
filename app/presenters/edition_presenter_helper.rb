module EditionPresenterHelper
  def link
    h.link_to model.title, public_document_path(model)
  end

  def published_at
    date_microformat(:published_at)
  end

  def display_date_microformat
    date_microformat(display_date_attribute_name)
  end

  def display_date
    model.send(display_date_attribute_name)
  end

  def date_microformat(attribute_name)
    h.render_datetime_microformat(model, attribute_name) {
      model.send(attribute_name).to_date.to_s(:long_ordinal)
    }
  end
end
