module Admin::AttachmentActionParamHandler
  def self.handle!(attachment_join_params)
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