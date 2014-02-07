class Admin::AttachmentsController < Admin::BaseController
  before_filter :limit_attachable_access, if: :attachable_is_an_edition?
  before_filter :check_attachable_allows_html_attachments, if: :html?

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
    @attachment ||= find_attachment || build_attachment
  end
  helper_method :attachment

  def find_attachment
    attachable.attachments.find(params[:id]) if params[:id]
  end

  def build_attachment
    html? ? build_html_attachment : build_file_attachment
  end

  def build_html_attachment
    HtmlAttachment.new(attachment_params)
  end

  def build_file_attachment
    FileAttachment.new(attachment_params).tap do |file_attachment|
      file_attachment.build_attachment_data unless file_attachment.attachment_data
    end
  end

  def attachment_params
    params.fetch(:attachment, {}).permit(
      :title, :body, :locale, :isbn, :unique_reference, :command_paper_number,
      :unnumbered_command_paper, :hoc_paper_number, :unnumbered_hoc_paper,
      :parliamentary_session, :order_url, :price, :accessible,
      :manually_numbered_headings,
      attachment_data_attributes: [:file, :to_replace_id, :file_cache]
    ).merge(attachable: attachable)
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

  def attachable_is_an_edition?
    attachable_class == Edition
  end

  def limit_attachable_access
    enforce_permission!(:see, attachable)
    enforce_permission!(:update, attachable)

    @edition = attachable
    prevent_modification_of_unmodifiable_edition
  end
end
