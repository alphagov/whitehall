class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper
  include PermissionsCheckerConcern

  layout "admin"
  prepend_before_action :authenticate_user!, except: %i[auth_failure]

  def auth_failure
    render "authentications/failure", status: :forbidden
  end

  def limit_edition_access!
    enforce_permission!(:see, @edition)
  end

  def require_fatality_handling_permission!
    forbidden! unless current_user.can_handle_fatalities?
  end

  def enforce_permission!(action, subject)
    unless can?(action, subject)
      raise Whitehall::Authority::Errors::PermissionDenied.new(action, subject)
    end
  end

  rescue_from Whitehall::Authority::Errors::PermissionDenied do |exception|
    logger.warn "Attempt to perform '#{exception.action}' on #{exception.subject} prevented."
    forbidden!
  end

  rescue_from Whitehall::Authority::Errors::InvalidAction do |exception|
    logger.warn "Attempt to perform unknown action '#{exception.action}' prevented."
    forbidden!
  end

  def prevent_modification_of_unmodifiable_edition
    if @edition.unmodifiable?
      notice = "You cannot modify a #{@edition.state} #{@edition.type.titleize}"
      redirect_to admin_edition_path(@edition), notice:
    end
  end

  def preview_design_system?(next_release: false)
    current_user.can_preview_design_system? || (next_release && current_user.can_preview_next_release?)
  end
  helper_method :preview_design_system?

  def render_design_system(design_system_view, legacy_view)
    if new_design_system?
      render design_system_view
    else
      render legacy_view
    end
  end

  def show_new_header?
    current_user.can_preview_design_system?
  end
  helper_method :show_new_header?

private

  def new_design_system?
    get_layout == "design_system"
  end

  def forbidden!
    render "admin/editions/forbidden", status: :forbidden
  end

  def typecast_for_attachable_routing(attachable)
    case attachable
    when Edition then attachable.becomes(Edition)
    when ConsultationResponse then attachable.becomes(ConsultationResponse)
    when CallForEvidenceResponse then attachable.becomes(CallForEvidenceResponse)
    else attachable
    end
  end
  helper_method :typecast_for_attachable_routing

  # Override the default Rails behaviour to raise an exception when receiving
  # unverified requests instead of nullifying the session
  def handle_unverified_request
    raise ActionController::InvalidAuthenticityToken
  end
end
