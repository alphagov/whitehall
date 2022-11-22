module Admin::TabbedNavHelper
  include Admin::EditionsHelper

  def secondary_navigation_tabs_items(model, current_path)
    if model.is_a?(Edition)
      edition_nav_items(model, current_path)
    elsif model.respond_to? :consultation
      edition_nav_items(model.consultation, current_path)
    else
      send("#{model.class.model_name.param_key}_nav_items", model, current_path)
    end
  end

  def edition_nav_items(edition, current_path)
    nav_items = []
    nav_items << standard_edition_nav_items(edition, current_path)
    nav_items << consultation_nav_items(edition, current_path) if edition.persisted? && edition.is_a?(Consultation)
    nav_items << document_collection_nav_items(edition, current_path) if edition.persisted? && edition.is_a?(DocumentCollection)
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

  def call_for_evidence_nav_items(edition, current_path)
    [
      {
        label: "Public feedback",
        href: admin_call_for_evidence_public_feedback_path(edition),
        current: current_path == admin_call_for_evidence_public_feedback_path(edition),
      },
      {
        label: "Final outcome",
        href: admin_call_for_evidence_outcome_path(edition),
        current: current_path == admin_call_for_evidence_outcome_path(edition),
      },
    ]
  end

  def document_collection_nav_items(edition, current_path)
    {
      label: "Collection documents",
      href: admin_document_collection_groups_path(edition),
      current: current_path == admin_document_collection_groups_path(edition),
    }
  end

  def policy_group_nav_items(group, current_path)
    [
      {
        label: "Group",
        href: edit_admin_policy_group_path(group),
        current: current_path == edit_admin_policy_group_path(group),
      },
      {
        label: sanitize("Attachments #{tag.span(group.attachments.count, class: 'govuk-tag govuk-tag--grey') if group.attachments.count.positive?}"),
        href: admin_policy_group_attachments_path(group),
        current: current_path == admin_policy_group_attachments_path(group),
      },
    ]
  end

  def tab_navigation_for(model, *extra_classes, &block)
    tabs = send("#{model.class.model_name.param_key}_tabs", model)
    tab_navigation(tabs, *extra_classes, &block)
  end

  def person_tabs(person)
    { "Details" => admin_person_path(person),
      "Translations" => admin_person_translations_path(person),
      "Historical accounts" => admin_person_historical_accounts_path(person) }
  end

  def topic_tabs(topic)
    {
      "Details" => url_for([:admin, topic]),
      "Features" => url_for([:admin, topic, :topical_event_featurings]),
    }
  end

  def corporate_information_page_tabs(page)
    {
      "Details" => polymorphic_path([:edit, :admin, page.organisation, page]),
      "Attachments" => admin_corporate_information_page_attachments_path(page.id),
    }
  end

  def policy_group_tabs(group)
    {
      "Group" => edit_admin_policy_group_path(group),
      "Attachments" => admin_policy_group_attachments_path(group),
    }
  end

  def tab_navigation(tabs, *extra_classes, &block)
    tabs = tab_navigation_header(tabs)
    tag.div(class: ["tabbable", *extra_classes]) do
      if block_given?
        tabs + tag.div(class: "tab-content", &block)
      else
        tabs
      end
    end
  end

  def tab_dropdown(label, menu_items)
    tag.li(class: "dropdown") do
      toggle = tag.a(class: "dropdown-toggle", 'data-toggle': "dropdown", href: "#") do
        "#{label} #{tag.b('', class: 'caret')}".html_safe
      end

      menu = tag.ul(class: "dropdown-menu") do
        menu_items
          .map { |sub_label, sub_content|
            tag.li(class: class_for_tab(sub_content)) do
              link_to(sub_label, sub_content)
            end
          }
          .join
          .html_safe
      end

      toggle + menu
    end
  end

  def tab_navigation_header(tabs)
    tag.ul(class: %w[nav nav-tabs add-bottom-margin]) do
      tabs.map { |label, content|
        if content.is_a?(Hash)
          tab_dropdown(label, content)
        else
          tag.li(link_to(label, content), class: class_for_tab(content))
        end
      }.join.html_safe
    end
  end

  def class_for_tab(url)
    request.path == url ? :active : nil
  end
end
