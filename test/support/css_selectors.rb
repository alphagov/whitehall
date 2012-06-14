module CssSelectors
  include ActionController::RecordIdentifier

  def record_css_selector(object)
    '#' + dom_id(object)
  end

  def record_id_from(element)
    element["id"].split("_").last
  end

  def records_from_elements(klass, elements)
    klass.find(elements.map { |element| record_id_from(element) })
  end

  def organisations_selector
    "#organisations"
  end

  def topics_selector
    "#topics"
  end

  def ministers_responsible_selector
    "#ministers_responsible"
  end

  def supporting_pages_selector
    "#supporting_pages"
  end

  def metadata_nav_selector
    ".meta"
  end

  def related_news_articles_selector
    "#related-news-articles"
  end

  def related_consultations_selector
    "#related-consultations"
  end

  def related_publications_selector
    "#related-publications"
  end

  def corporate_publications_selector
    "#corporate-publications"
  end

  def inapplicable_nations_selector
    "#inapplicable_nations"
  end

  def notes_to_editors_selector
    "#notes_to_editors"
  end

  def parent_organisations_list_selector
    "select[name='organisation[parent_organisation_ids][]']"
  end

  def organisation_type_list_selector
    "select[name='organisation[organisation_type_id]']"
  end

  def organisation_topics_list_selector
    "select[name='organisation[topic_ids][]']"
  end

  def permanent_secretary_board_members_selector
    "#permanent_secretary_board_members"
  end

  def other_board_members_selector
    "#other_board_members"
  end

  def featured_news_articles_selector
    "#featured-news-articles"
  end

  def featured_consultations_selector
    ".consultation.featured"
  end

  def countries_selector
    "#countries"
  end

  def publish_form_selector(document)
    "form[action=#{CGI::escapeHTML(publish_admin_edition_path(document, lock_version: document.lock_version))}]"
  end

  def force_publish_form_selector(document)
    "form[action=#{CGI::escapeHTML(publish_admin_edition_path(document, force: true, lock_version: document.lock_version))}]"
  end

  def reject_button_selector(document)
    "form[action=#{CGI::escapeHTML(reject_admin_edition_path(document, lock_version: document.lock_version))}] input[type=submit][value=Reject]"
  end

  def link_to_public_version_selector
    ".actions .public_version"
  end
end