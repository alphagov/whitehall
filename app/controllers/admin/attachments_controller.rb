class Admin::AttachmentsController < Admin::BaseController
  before_action :limit_attachable_access, if: :attachable_is_an_edition?
  before_action :check_attachable_allows_attachment_type, only: %i[create new update edit]
  before_action :update_attachment_params, only: :update

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
      flash[:notice] = "Attachment '#{attachment.title}' uploaded"
      save_and_redirect
    else
      render :new
    end
  end

  def edit; end

  def update
    if save_attachment
      flash[:notice] = "Attachment '#{attachment.title}' updated"
      save_and_redirect
    else
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    attachment.destroy!
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
    Attachment.new(attachment_params)
  end

  def attachment_params
    params.fetch(:attachment, {}).permit(
      :title,
    ).merge(attachable:)
  end

  def type
    attachment.readable_type.downcase
  end
  helper_method :type

  def check_attachable_allows_attachment_type
    redirect_to attachable_attachments_path(attachable) unless attachable.allows_attachment_type?(type)
  end

  def attachable_param
    params.keys.find { |k| k =~ /_id$/ }
  end

  def attachable_class
    # Note - this case statement needs to include a clause for every resource
    # in the routes.rb file which has resources :attachments nested under it.
    # For example, if we have the following in routes.rb:
    #
    #  resources :consultation_responses do
    #    resources :attachments
    #  end
    #
    # We need to add a clause like:
    #
    #   when "consultation_response_id" then ConsultationResponse
    #
    case attachable_param
    when "edition_id" then Edition
    when "consultation_response_id" then ConsultationResponse
    when "call_for_evidence_response_id" then CallForEvidenceResponse
    when "worldwide_organisation_page_id" then WorldwideOrganisationPage
    when "corporate_information_page_id" then CorporateInformationPage
    when "policy_group_id" then PolicyGroup
    else
      logger.warn("Unexpected attachable_param name #{attachable_param}")
      raise ActiveRecord::RecordNotFound
    end
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
    result = attachment.save(context: :user_input)

    attachable_draft_updater

    result
  end

  def attachment_updater(attachment_data)
    ServiceListeners::AttachmentUpdater.call(attachment_data:)
  end

  def attachable_draft_updater
    return unless attachable_is_an_edition?

    draft_updater = Whitehall.edition_services.draft_updater(attachable)
    draft_updater.perform!
  end

  def update_attachment_params
    attachment.attributes = attachment_params
  end

  def save_and_redirect
    attachment_updater(attachment.attachment_data)
    redirect_to_attachments_index
  end

  def redirect_to_attachments_index(bulk_upload_error: nil)
    flash[:bulk_upload_error] = bulk_upload_error
    redirect_to attachable_attachments_path(attachable), flash: { bulk_upload_error: }
  end

  def attachable_model_name
    attachable.class.model_name.human.downcase
  end
  helper_method :attachable_model_name
end
