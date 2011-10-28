module Admin::DocumentsHelper
  def inapplicability_checkbox_options(form)
    checked_value, unchecked_value = '0', '1'
    checked = form.object[:_destroy].present? ? (form.object[:_destroy] == checked_value) : form.object.persisted?
    [{ checked: checked }, checked_value, unchecked_value]
  end

  def admin_documents_state_path(state, options = {})
    case state.to_s
    when 'submitted'
      submitted_admin_documents_path(options)
    when 'published'
      published_admin_documents_path(options)
    else
      admin_documents_path(options)
    end
  end

  def current_filter_class(filter)
    if (params[:filter].to_s == filter.to_s) || (filter == 'all' && params[:filter].blank?)
      {class: 'current'}
    else
      {}
    end
  end
end