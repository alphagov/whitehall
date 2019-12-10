class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper
  include PermissionsChecker

  layout "admin"
  prepend_before_action :skip_slimmer
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

  def require_import_permission!
    authorise_user!(User::Permissions::IMPORT)
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
      redirect_to admin_edition_path(@edition), notice: notice
    end
  end

  def forbid_editing_of_locked_documents
    if @edition.locked?
      redirect_to show_locked_admin_edition_path(@edition),
                  alert: %{This document is locked and cannot be edited}
    end
  end

private

  def forbidden!
    render "admin/editions/forbidden", status: :forbidden
  end

  def typecast_for_attachable_routing(attachable)
    case attachable
    when Edition then attachable.becomes(Edition)
    when Response then attachable.becomes(Response)
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
