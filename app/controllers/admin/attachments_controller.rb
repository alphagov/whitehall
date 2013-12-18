class Admin::AttachmentsController < Admin::BaseController
  before_filter :assign_edition, if: :attachable_is_an_edition?
  before_filter :limit_edition_access!, if: :attachable_is_an_edition?
  before_filter :enforce_edition_permissions!, if: :attachable_is_an_edition?
  before_filter :prevent_modification_of_unmodifiable_edition, if: :attachable_is_an_edition?
  before_filter :check_attachable_allows_html_attachments, if: :html?
  before_filter :find_attachment, only: [:edit, :update, :destroy]

  def index; end

  def order
    attachment_ids = params[:ordering].sort_by { |_, ordering| ordering.to_i }.map { |id, _| id }
    attachable.reorder_attachments(attachment_ids)

    redirect_to attachable_attachments_path(attachable), notice: 'Attachments re-ordered'
  end

  def new; end

  def create
    if attachment.save
      redirect_to attachable_attachments_path(attachable), notice: "Attachment '#{attachment.title}' uploaded"
    else
      render :new
    end
  end

  def update
    if attachment.update_attributes(attachment_params)
      message = "Attachment '#{attachment.title}' updated"
      redirect_to attachable_attachments_path(attachable), notice: message
    else
      render :edit
    end
  end

  def destroy
    attachment.destroy
    redirect_to attachable_attachments_path(attachable), notice: 'Attachment deleted'
  end

  def attachable_attachments_path(attachable)
    case attachable
    when Response
      [:admin, attachable.consultation, attachable.singular_routing_symbol]
    else
      [:admin, typecast_for_attachable_routing(attachable), Attachment]
    end
  end
  helper_method :attachable_attachments_path

private
  def attachment
    @attachment ||= begin
      attachment_class = html? ? HtmlAttachment : FileAttachment

      attachment_params = params[:attachment] || {}
      attachment_params.merge!(attachable: attachable)
      attachment_params.reverse_merge!(attachment_data: AttachmentData.new) if attachment_class == FileAttachment

      attachment_class.new(attachment_params)
    end
  end
  helper_method :attachment

  def find_attachment
    @attachment = attachable.attachments.find(params[:id])
  end

  def attachment_params
    data_attributes = params[:attachment][:attachment_data_attributes]
    if data_attributes && data_attributes[:file]
      params[:attachment]
    else
      params[:attachment].except(:attachment_data_attributes)
    end
  end

  def enforce_edition_permissions!
    enforce_permission!(:update, attachable)
  end

  def attachable_is_an_edition?
    attachable.is_a?(Edition)
  end

  def html?
    params[:html] == 'true'
  end

  def check_attachable_allows_html_attachments
    redirect_to attachable_attachments_path(attachable) unless attachable.allows_html_attachments?
  end

  def attachable_param
    params.keys.find { |k| k =~ /_id$/ }
  end

  def attachable_class
    if attachable_param
      attachable_param.sub(/_id$/, '').classify.constantize
    else
      raise ActiveRecord::RecordNotFound
    end
  rescue NameError
    raise ActiveRecord::RecordNotFound
  end

  def attachable_id
    params[attachable_param]
  end

  def attachable
    @attachable ||= attachable_class.find(attachable_id)
  end
  helper_method :attachable

  def assign_edition
    @edition = attachable
  end
end
