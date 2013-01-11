module Admin::EditionsController::Attachments
  extend ActiveSupport::Concern

  included do
    before_filter :build_edition_attachment, only: [:new, :edit]
    before_filter :cope_with_attachment_action_params, only: [:update]
  end

  def build_edition_dependencies
    super
    build_edition_attachment
  end

  def build_edition_attachment
    @edition.build_empty_attachment
  end

  def cope_with_attachment_action_params
    return unless params[:edition] && params[:edition][:edition_attachments_attributes]
    params[:edition][:edition_attachments_attributes].each do |_, edition_attachment_params|
      if edition_attachment_params[:attachment_attributes] && edition_attachment_params[:id]
        case edition_attachment_params[:attachment_attributes].delete(:attachment_action).to_s.downcase
        when 'keep'
          edition_attachment_params.delete(:_destroy)
          edition_attachment_params[:attachment_attributes].delete(:attachment_data_attributes)
        when 'remove'
          edition_attachment_params['_destroy'] = '1'
          edition_attachment_params[:attachment_attributes].delete(:attachment_data_attributes)
        when 'replace'
          edition_attachment_params.delete(:_destroy)
          edition_attachment_params[:attachment_attributes][:attachment_data_attributes].delete(:id)
        else
          edition_attachment_params.delete(:_destroy)
          edition_attachment_params[:attachment_attributes].delete(:attachment_data_attributes)
        end
      end
    end
  end
end
