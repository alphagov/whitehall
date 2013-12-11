module Admin::TabbedNavHelper
  def tab_navigation_for(model, *extra_classes, &block)
    tabs = send("#{model.class.model_name.underscore}_tabs", model)
    tab_navigation(tabs, *extra_classes, &block)
  end

  def person_tabs(person)
    { 'Details' => admin_person_path(person),
      'Translations' => admin_person_translations_path(person),
      'Historical accounts' => admin_person_historical_accounts_path(person) }
  end

  def topic_tabs(topic)
    {
      "Details" => url_for([:admin, topic]),
      "Featured documents" => url_for([:admin, topic, :classification_featurings])
    }
  end

  def corporate_information_page_tabs(page)
    {
      'Details' => edit_admin_organisation_corporate_information_page_path(page.organisation, page),
      'Attachments' => admin_corporate_information_page_attachments_path(page.id)
    }
  end

  def tab_navigation(tabs, *extra_classes, &block)
    tabs = tab_navigation_header(tabs)
    content_tag(:div, class: ['tabbable', *extra_classes] ) do
      if block_given?
        tabs + content_tag(:div, class: "tab-content") { yield }
      else
        tabs
      end
    end
  end

  def tab_dropdown(label, menu_items)
    content_tag(:li, class: 'dropdown') do
      content_tag(:a, class: 'dropdown-toggle', :'data-toggle' => 'dropdown', href: '#') do
        (label + " " + content_tag(:b, '', class: 'caret')).html_safe
      end +
      content_tag(:ul, class: 'dropdown-menu') do
        menu_items.map { |sub_label, sub_content|
          content_tag(:li, link_to(sub_label, sub_content), class: class_for_tab(sub_content))
        }.join.html_safe
      end
    end
  end

  def tab_navigation_header(tabs)
    content_tag(:ul, class: %w(nav nav-tabs)) do
      tabs.map { |label, content|
        if content.is_a?(Hash)
          tab_dropdown(label, content)
        else
          content_tag(:li, link_to(label, content), class: class_for_tab(content))
        end
      }.join.html_safe
    end
  end

  def class_for_tab(url)
    request.path == url ? :active : nil
  end
end
