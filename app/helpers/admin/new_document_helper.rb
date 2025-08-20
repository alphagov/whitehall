module Admin::NewDocumentHelper
  def radio_buttons_for(document_types)
    document_types.inject([]) do |radio_buttons, (type_key, type_hash)|
      radio_buttons << {
        value: type_key,
        text: type_hash["label"],
        bold: true,
        hint_text: type_hash["hint_text"],
      }
    end
  end
end
