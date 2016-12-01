module Admin::AttachableHelper
  def attachable_editing_tabs(attachable, &block)
    case attachable
    when Consultation
      consultation_editing_tabs(attachable, &block)
    when Response
      consultation_editing_tabs(attachable.consultation, &block)
    when Edition
      edition_editing_tabs(attachable, &block)
    else
      tab_navigation_for(attachable, &block)
    end
  end

  def attachment_action_fields(fields, data_object_name = :attachment_data)
    return if fields.object.new_record?
    keep_destroy_or_replace =
      if fields.object[:_destroy].present? && fields.object[:_destroy] == '1'
        'destroy'
      elsif fields.object.send(data_object_name).file_cache.present?
        'replace'
      else
        'keep'
      end
    [
      fields.labelled_radio_button('Keep', :attachment_action, 'keep', checked: keep_destroy_or_replace == 'keep'),
      fields.labelled_radio_button('Remove', :attachment_action, 'remove', checked: keep_destroy_or_replace == 'destroy'),
      fields.labelled_radio_button('Replace', :attachment_action, 'replace', checked: keep_destroy_or_replace == 'replace'),
    ].join.html_safe
  end

  def consultation_response_form_data_fields(response_form_fields)
    object = response_form_fields.object.consultation_response_form_data
    if object.nil? && !response_form_fields.object.persisted?
      object = response_form_fields.object.build_consultation_response_form_data
    end

    response_form_fields.fields_for(:consultation_response_form_data, object) do |data_fields|
      contents = []
      contents << data_fields.label(:file, 'Replacement') if response_form_fields.object.persisted?
      contents << data_fields.file_field(:file)
      if data_fields.object.file_cache.present?
        text = "#{File.basename(data_fields.object.file_cache)} already uploaded"
        text << " as replacement" if response_form_fields.object.persisted?
        contents << content_tag(:span, text, class: 'already_uploaded')
      end
      contents << data_fields.hidden_field(:file_cache)
      contents.join.html_safe
    end
  end
end
