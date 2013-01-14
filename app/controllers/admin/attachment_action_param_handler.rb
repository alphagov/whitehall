module Admin::AttachmentActionParamHandler
  def self.manipulate_params!(attachment_join_params)
    # Investigates attachment_join params for those trying to update an
    # existing attachment instance (has id and attachment_attributes).
    # Based on the value of the acttachment_action param, it manipulates
    # the params to behave properly and keep, remove, or replace the
    # attachment and it's underlying attachment_data instance.
    # The absence of an attachment_action param, or an unexpected value is
    # considered the same as a value of 'keep', as that's the least
    # destructive.
    if attachment_join_params[:attachment_attributes] && attachment_join_params[:id]
      case attachment_join_params[:attachment_attributes].delete(:attachment_action).to_s.downcase
      when 'keep'
        attachment_join_params.delete(:_destroy)
        attachment_join_params[:attachment_attributes].delete(:attachment_data_attributes)
      when 'remove'
        attachment_join_params['_destroy'] = '1'
        attachment_join_params[:attachment_attributes].delete(:attachment_data_attributes)
      when 'replace'
        attachment_join_params.delete(:_destroy)
        attachment_join_params[:attachment_attributes][:attachment_data_attributes].delete(:id)
      else
        attachment_join_params.delete(:_destroy)
        attachment_join_params[:attachment_attributes].delete(:attachment_data_attributes)
      end
    end
  end
end