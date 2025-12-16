class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper
  include PermissionsCheckerConcern

  layout "design_system"
  prepend_before_action :authenticate_user!

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
      alert = "You cannot modify a #{@edition.state} #{@edition.full_display_title}"
      redirect_to admin_edition_path(@edition), alert:
    end
  end

  def product_name
    Whitehall.product_name
  end
  helper_method :product_name

private

  def forbidden!
    render "admin/errors/forbidden", status: :forbidden
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
