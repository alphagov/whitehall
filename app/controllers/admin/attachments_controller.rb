class Admin::AttachmentsController < Admin::BaseController
  before_filter :find_attachable
  before_filter :limit_edition_access!, if: :attachable_is_an_edition?
  before_filter :enforce_edition_permissions!, if: :attachable_is_an_edition?
  before_filter :prevent_modification_of_unmodifiable_edition, if: :attachable_is_an_edition?
  before_filter :find_attachment, only: [:edit, :update, :destroy]

  def index; end

  def order
    uniquify_ordering(params[:ordering]).each do |attachment_id, ordering|
      @attachable.attachments.find(attachment_id).update_column(:ordering, ordering)
    end
    redirect_to attachable_attachments_path(@attachable), notice: 'Attachments re-ordered'
  end

  def new; end

  def create
    if attachment.save
      redirect_to attachable_attachments_path(@attachable), notice: "Attachment '#{attachment.title}' uploaded"
    else
      render :new
    end
  end

  def update
    if attachment.update_attributes(attachment_params)
      message = "Attachment '#{attachment.title}' updated"
      redirect_to attachable_attachments_path(@attachable), notice: message
    else
      render :edit
    end
  end

  def destroy
    attachment.destroy
    redirect_to attachable_attachments_path(@attachable), notice: 'Attachment deleted'
  end

private
  def attachment
    @attachment ||= begin
      attachment_class = html? ? HtmlAttachment : FileAttachment

      attachment_params = params[:attachment] || {}
      attachment_params.merge!(attachable: @attachable)
      attachment_params.reverse_merge!(attachment_data: AttachmentData.new) if attachment_class == FileAttachment

      attachment_class.new(attachment_params)
    end
  end
  helper_method :attachment

  def find_attachable
    @attachable =
      if params.has_key?(:edition_id)
        @edition = Edition.find(params[:edition_id])
      elsif params.has_key?(:response_id)
        Response.find(params[:response_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_attachment
    @attachment = @attachable.attachments.find(params[:id])
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
    enforce_permission!(:update, @attachable)
  end

  def attachable_is_an_edition?
    @attachable.is_a?(Edition)
  end

  def html?
    params[:html] == 'true'
  end

  # Attachment has a unique constraint on attachable type/id and ordering.
  # This stops us simple changing the ordering values of existing
  # attachments, as two rows end up with the same ordering value during
  # the update, violating the constraint. To get around it, if all the new
  # ordering values are less than the lowest ordering value currently
  # stored we just use them. Otherwise, we renumber the new ordering
  # values to start above the existing maximum value.
  def uniquify_ordering(ordering_params)
    return ordering_params if ordering_params.empty?

    min_existing = @attachable.attachments.minimum(:ordering)
    max_new = ordering_params.values.map(&:to_i).max

    if max_new < min_existing
      ordering_params
    else
      max_existing = @attachable.attachments.maximum(:ordering)
      Hash[ordering_params.map { |id, order| [id, order.to_i + max_existing + 1] }].with_indifferent_access
    end
  end
end
