module Admin::TabbedNavHelper
  include Admin::EditionsHelper

  def secondary_navigation_tabs_items(model, current_path)
    if model.is_a?(Edition)
      edition_nav_items(model, current_path)
    elsif model.respond_to? :consultation
      edition_nav_items(model.consultation, current_path)
    elsif model.respond_to? :call_for_evidence
      edition_nav_items(model.call_for_evidence, current_path)
    else
      send("#{model.class.model_name.param_key}_nav_items", model, current_path)
    end
  end

  def edition_nav_items(edition, current_path)
    nav_items = []
    nav_items << standard_edition_nav_items(edition, current_path)
    nav_items << images_nav_items(edition, current_path)
    nav_items << consultation_nav_items(edition, current_path) if edition.persisted? && edition.is_a?(Consultation)
    nav_items << call_for_evidence_nav_items(edition, current_path) if edition.persisted? && edition.is_a?(CallForEvidence)
    nav_items << document_collection_nav_items(edition, current_path) if edition.persisted? && edition.is_a?(DocumentCollection)
    nav_items << worldwide_organisation_nav_items(edition, current_path) if edition.persisted? && edition.is_a?(WorldwideOrganisation)
    nav_items << social_media_nav_items(edition, current_path) if edition.persisted? && edition.can_be_associated_with_social_media_accounts?
    nav_items.flatten
  end

  def standard_edition_nav_items(edition, current_path)
    [
      {
        label: "Document",
        href: tab_url_for_edition(edition),
        current: current_path == tab_url_for_edition(edition),
      },
      *(if edition.persisted? && edition.allows_attachments?
          [{
            label: sanitize("Attachments #{tag.span(edition.attachments.count, class: 'govuk-tag govuk-tag--grey') if edition.attachments.count.positive?}"),
            href: admin_edition_attachments_path(edition),
            current: current_path == admin_edition_attachments_path(edition),
          }]
        end),
    ]
  end

  def images_nav_items(edition, current_path)
    [
      *(if edition.persisted? && edition.allows_image_attachments?
          [{
            label: sanitize("Images #{tag.span(edition.images.count, class: 'govuk-tag govuk-tag--grey') if edition.images.count.positive?}"),
            href: admin_edition_images_path(edition),
            current: current_path == admin_edition_images_path(edition),
          }]
        end),
    ]
  end

  def call_for_evidence_nav_items(edition, current_path)
    [
      {
        label: "Outcome",
        href: admin_call_for_evidence_outcome_path(edition),
        current: current_path == admin_call_for_evidence_outcome_path(edition),
      },
    ]
  end

  def consultation_nav_items(edition, current_path)
    [
      {
        label: "Public feedback",
        href: admin_consultation_public_feedback_path(edition),
        current: current_path == admin_consultation_public_feedback_path(edition),
      },
      {
        label: "Final outcome",
        href: admin_consultation_outcome_path(edition),
        current: current_path == admin_consultation_outcome_path(edition),
      },
    ]
  end

  def document_collection_nav_items(edition, current_path)
    collection_documents_element = {
      label: "Collections",
      href: admin_document_collection_groups_path(edition),
      current: current_path == admin_document_collection_groups_path(edition),
    }
    email_notifications_element = {
      label: "Email notifications",
      href: admin_document_collection_edit_email_subscription_path(edition),
      current: current_path == admin_document_collection_edit_email_subscription_path(edition),
    }
    if edition.has_topic_level_notifications?
      [collection_documents_element, email_notifications_element]
    else
      [collection_documents_element]
    end
  end

  def document_collection_group_nav_items(group, current_path)
    [
      {
        label: "Documents",
        href: admin_document_collection_group_document_collection_group_memberships_path(group.document_collection, group),
        current: current_path == admin_document_collection_group_document_collection_group_memberships_path(group.document_collection, group),
      },
      {
        label: "Group details",
        href: admin_document_collection_group_path(group.document_collection, group),
        current: current_path == admin_document_collection_group_path(group.document_collection, group),
      },
    ]
  end

  def social_media_nav_items(edition, current_path)
    [
      {
        label: "Social media accounts",
        href: admin_edition_social_media_accounts_path(edition),
        current: current_path == admin_edition_social_media_accounts_path(edition),
      },
    ]
  end

  def policy_group_nav_items(group, current_path)
    [
      {
        label: "Group",
        href: edit_admin_policy_group_path(group),
        current: current_path == edit_admin_policy_group_path(group) || current_path == admin_policy_group_path(group),
      },
      {
        label: sanitize("Attachments #{tag.span(group.attachments.count, class: 'govuk-tag govuk-tag--grey') if group.attachments.count.positive?}"),
        href: admin_policy_group_attachments_path(group),
        current: current_path == admin_policy_group_attachments_path(group),
      },
    ]
  end

  def person_nav_items(person, current_path)
    [
      {
        label: "Details",
        href: admin_person_path(person),
        current: current_path == admin_person_path(person),
      },
      {
        label: "Translations",
        href: admin_person_translations_path(person),
        current: current_path == admin_person_translations_path(person),
      },
      {
        label: "Historical accounts",
        href: admin_person_historical_accounts_path(person),
        current: current_path == admin_person_historical_accounts_path(person),
      },
    ]
  end

  def worldwide_organisation_nav_items(worldwide_organisation, current_path)
    [
      {
        label: "Offices",
        href: admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation),
        current: current_path == admin_worldwide_organisation_worldwide_offices_path(worldwide_organisation),
      },
      {
        label: "Pages",
        href: admin_worldwide_organisation_pages_path(worldwide_organisation),
        current: current_path == admin_worldwide_organisation_pages_path(worldwide_organisation),
      },
    ]
  end

  def worldwide_organisation_page_nav_items(page, current_path)
    [
      {
        label: "Page",
        href: edit_admin_worldwide_organisation_page_path(page.edition, page),
        current: current_path == edit_admin_worldwide_organisation_page_path(page.edition, page),
      },
      {
        label: sanitize("Attachments #{tag.span(page.attachments.count, class: 'govuk-tag govuk-tag--grey') if page.attachments.count.positive?}"),
        href: admin_worldwide_organisation_page_attachments_path(page),
        current: current_path == admin_worldwide_organisation_page_attachments_path(page),
      },
    ]
  end
end
