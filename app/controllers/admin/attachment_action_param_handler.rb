module Admin::AttachmentActionParamHandler
  private
  def cope_with_attachment_action_params
    page_params_key = controller_name.singularize.to_sym
    attachments_attributes = params.fetch(page_params_key, {}).fetch(:attachments_attributes, {})
    attachments_attributes.each do |_, attachment_attributes|
      manipulate_params_for_attachment!(attachment_attributes)
    end
  end

  def manipulate_params_for_attachment!(attachment_params)
    # Investigates attachment_join params for those trying to update an
    # existing attachment instance (has id and attachment_attributes).
    # Based on the value of the attachment_action param, it manipulates
    # the params to behave properly and keep, remove, or replace the
    # attachment and it's underlying attachment_data instance.
    # The absence of an attachment_action param, or an unexpected value is
    # considered the same as a value of 'keep', as that's the least
    # destructive.
    if attachment_params[:attachment_action] && attachment_params[:id]
      case attachment_params.delete(:attachment_action).to_s.downcase
      when 'keep'
        attachment_params.delete(:_destroy)
        attachment_params.delete(:attachment_data_attributes)
      when 'remove'
        attachment_params['_destroy'] = '1'
        attachment_params.delete(:attachment_data_attributes)
      when 'replace'
        attachment_params.delete(:_destroy)
        attachment_params[:attachment_data_attributes].delete(:id)
      else
        attachment_params.delete(:_destroy)
        attachment_params.delete(:attachment_data_attributes)
      end
    end
  end
end
