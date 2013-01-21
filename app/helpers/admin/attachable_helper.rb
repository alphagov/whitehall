module Admin::AttachableHelper
  def attachment_action_fields(fields)
    return if fields.object.new_record?
    keep_destroy_or_replace =
      if fields.object[:_destroy].present? && fields.object[:_destroy] == '1'
        'destroy'
      elsif fields.object.attachment_data.file_cache.present?
        'replace'
      else
        'keep'
      end
    [
      label_tag(nil, class: 'radio inline') do
        fields.radio_button(:attachment_action, 'keep', checked: keep_destroy_or_replace == 'keep')+ ' Keep'
      end,
      label_tag(nil, class: 'radio inline') do
        fields.radio_button(:attachment_action, 'remove', checked: keep_destroy_or_replace == 'destroy')+' Remove'
      end,
      label_tag(nil, class: 'radio inline') do
        fields.radio_button(:attachment_action, 'replace', checked: keep_destroy_or_replace == 'replace')+' Replace'
      end
    ].join.html_safe
  end

  def replacement_attachment_data_fields(fields)
    return if fields.object.new_record?
    fields.fields_for(:attachment_data, include_id: false) do |attachment_data_fields|
      contents = [
        attachment_data_fields.hidden_field(:to_replace_id, value: attachment_data_fields.object.to_replace_id || attachment_data_fields.object.id),
        attachment_data_fields.label(:file, 'Replacement'),
        attachment_data_fields.file_field(:file)
      ]
      if attachment_data_fields.object.file_cache.present?
        text = "#{File.basename(attachment_data_fields.object.file_cache)} already uploaded as replacement"
        contents << content_tag(:span, text, class: 'already_uploaded')
      end
      contents << attachment_data_fields.hidden_field(:file_cache)
      contents.join.html_safe
    end
  end
end