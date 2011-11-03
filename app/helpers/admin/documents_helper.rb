module Admin::DocumentsHelper
  def nested_attribute_destroy_checkbox_options(form)
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [{ checked: checked }, checked_value, unchecked_value]
  end

  def link_to_filter(link, options)
    link_to link, url_for(options), class: filter_class(options)
  end

  def filter_class(options)
    current = options.keys.all? do |key|
      options[key] == params[key]
    end

    'current' if current
  end
end