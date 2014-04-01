module CssSelectors
  include ActionController::RecordIdentifier

  def record_css_selector(object, prefix = nil)
    '#' + dom_id(object, prefix)
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

  def metadata_nav_selector
    ".meta"
  end

  def corporate_publications_selector
    "#corporate-publications"
  end

  def inapplicable_nations_selector
    ".inapplicable-nations"
  end

  def parent_organisations_list_selector
    "select[name='organisation[parent_organisation_ids][]']"
  end

  def organisation_type_list_selector
    "select[name='organisation[organisation_type_id]']"
  end

  def organisation_topics_list_selector
    "select[name='organisation[organisation_classifications_attributes][][classification_id]']"
  end

  def organisation_govuk_status_selector
    "select[name='organisation[govuk_status]']"
  end

  def management_selector
    "#management"
  end

  def special_representative_selector
    "#special_representatives"
  end

  def featured_documents_selector
    "#featured-documents"
  end

  def world_locations_selector
    "#world-locations"
  end

  def publish_form_selector(document)
    "form[action=#{CGI::escapeHTML(publish_admin_edition_path(document, lock_version: document.lock_version))}]"
  end

  def force_publish_button_selector(document)
    "a[href='#{CGI::escapeHTML(confirm_force_publish_admin_edition_path(document, lock_version: document.lock_version))}']"
  end

  def reject_button_selector(document)
    "form[action=#{CGI::escapeHTML(reject_admin_edition_path(document, lock_version: document.lock_version))}] input[type=submit][value=Reject]"
  end

  def schedule_button_selector(document)
    "form[action=#{CGI::escapeHTML(schedule_admin_edition_path(document, lock_version: document.lock_version))}] input[type=submit][value=Schedule]"
  end

  def unschedule_button_selector(document)
    "form[action=#{CGI::escapeHTML(unschedule_admin_edition_path(document, lock_version: document.lock_version))}] input[type=submit][value=Unschedule]"
  end

  def force_schedule_button_selector(document)
    "form[action=#{CGI::escapeHTML(schedule_admin_edition_path(document, force: true, lock_version: document.lock_version))}] input[type=submit][value='Force schedule']"
  end

  def link_to_public_version_selector
    ".public_version"
  end

  def link_to_preview_version_selector
    ".preview_version"
  end

  def policy_group_selector
    ".policy_group"
  end
end
