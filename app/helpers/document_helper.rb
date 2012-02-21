module DocumentHelper
  def published_or_updated(document)
    document.first_edition? ? 'published' : 'updated'
  end

  def change_history(document)
    history = document.editions_ever_published.map do |e|
      {published_at: e.published_at, change_note: e.change_note}
    end
    history.last[:change_note] ||= "First published." if history.last
    history.reject { |e| e[:change_note].blank? }
  end

  def document_page_header(title, description)
    content_tag(:section, class: "page_header") do
      concat content_tag(:h1, title)
      concat content_tag(:p, description)
    end
  end

  def document_organisation_class(document)
    if document.organisations.first
      document.organisations.first.slug
    else
      'unknown_organisation'
    end
  end
end
