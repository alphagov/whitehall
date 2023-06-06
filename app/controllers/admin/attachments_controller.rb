class Admin::AttachmentsController < Admin::BaseController
  before_action :limit_attachable_access, if: :attachable_is_an_edition?
  before_action :check_attachable_allows_attachment_type
  layout "design_system"

  rescue_from Mysql2::Error, with: :handle_duplicate_key_errors_caused_by_double_create_requests

  def index; end

  def reorder; end

  def order
    attachment_ids = params.permit!.to_h[:ordering].sort_by { |_, ordering| ordering.to_i }.map { |id, _| id }
    attachable.reorder_attachments(attachment_ids)

    redirect_to attachable_attachments_path(attachable), notice: "Attachments re-ordered"
  end

  def new; end

  def create
    if save_attachment
      attachment_updater(attachment.attachment_data)
      redirect_to attachable_attachments_path(attachable), notice: "Attachment '#{attachment.title}' uploaded"
    else
      render :new
    end
  end

  def edit; end

  def update
    attachment.attributes = attachment_params
    if attachment.is_a?(FileAttachment)
      attachment.attachment_data.attachable = attachable
    end
    if save_attachment
      attachment_updater(attachment.attachment_data)
      message = "Attachment '#{attachment.title}' updated"
      redirect_to attachable_attachments_path(attachable), notice: message
    else
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    attachment_data = attachment.attachment_data
    attachment.destroy!
    attachment_updater(attachment_data)
    redirect_to attachable_attachments_path(attachable), notice: "Attachment deleted"
  end

  def attachable_attachments_path(attachable)
    case attachable
    when ConsultationResponse
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
    case type
    when "html"
      build_html_attachment
    when "external"
      build_external_attachment
    else
      build_file_attachment
    end
  end

  def build_html_attachment
    HtmlAttachment.new(attachment_params).tap do |attachment|
      attachment.build_govspeak_content if attachment.govspeak_content.blank?
    end
  end

  def build_external_attachment
    ExternalAttachment.new(attachment_params)
  end

  def build_file_attachment
    FileAttachment.new(attachment_params).tap do |file_attachment|
      file_attachment.build_attachment_data unless file_attachment.attachment_data
      file_attachment.attachment_data.attachable = attachable
    end
  end

  def attachment_params
    params.fetch(:attachment, {}).permit(
      :title,
      :locale,
      :isbn,
      :unique_reference,
      :command_paper_number,
      :unnumbered_command_paper,
      :hoc_paper_number,
      :unnumbered_hoc_paper,
      :parliamentary_session,
      :accessible,
      :external_url,
      govspeak_content_attributes: %i[id body manually_numbered_headings],
      attachment_data_attributes: %i[file to_replace_id file_cache],
    ).merge(attachable:)
  end

  def type
    params[:type].presence || "file"
  end

  def check_attachable_allows_attachment_type
    redirect_to attachable_attachments_path(attachable) unless attachable.allows_attachment_type?(type)
  end

  def attachable_param
    params.keys.find { |k| k =~ /_id$/ }
  end

  def attachable_class
    if attachable_param
      attachable_param.sub(/_id$/, "").classify.constantize
    else
      raise ActiveRecord::RecordNotFound
    end
  rescue NameError
    raise ActiveRecord::RecordNotFound
  end

  def attachable_id
    params[attachable_param]
  end

  def attachable_scope
    attachable_class.respond_to?(:friendly) ? attachable_class.friendly : attachable_class
  end

  def attachable
    @attachable ||= attachable_scope.find(attachable_id)
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

  def handle_duplicate_key_errors_caused_by_double_create_requests(exception)
    if action_name == "create" && exception.message =~ /Duplicate entry .+ for key 'no_duplicate_attachment_orderings'/
      redirect_to attachable_attachments_path(attachable), notice: "Attachment '#{attachment.title}' uploaded"
    else
      raise
    end
  end

  def save_attachment
    if use_non_legacy_endpoints?
      logger.info("Feature flag #{User::Permissions::USE_NON_LEGACY_ENDPOINTS} is set to true.")
    else
      logger.info("Feature flag #{User::Permissions::USE_NON_LEGACY_ENDPOINTS} is set to false.")
    end
    result = attachment.save(context: :user_input)

    if result && attachment.is_a?(HtmlAttachment)
      Whitehall::PublishingApi.save_draft(attachment)
    end

    if attachable_is_an_edition?
      @draft_updater ||= Whitehall.edition_services.draft_updater(attachable)

      if @draft_updater.can_perform?
        @draft_updater.perform!
      end
    end

    result
  end

  def attachment_updater(attachment_data)
    ServiceListeners::AttachmentUpdater.call(attachment_data:)
  end

  def use_non_legacy_endpoints?
    current_user.can_use_non_legacy_endpoints?
  end
end
