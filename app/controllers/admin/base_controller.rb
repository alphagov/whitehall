class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper
  include PermissionsChecker

  layout 'admin'
  prepend_before_filter :authenticate_user!
  before_filter :require_signin_permission!
  before_filter :skip_slimmer

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

  private

  def forbidden!
    render "admin/editions/forbidden", status: 403
  end

  def typecast_for_attachable_routing(attachable)
    case attachable
    when Edition then attachable.becomes(Edition)
    when Response then attachable.becomes(Response)
    else attachable
    end
  end
  helper_method :typecast_for_attachable_routing

  def user_can_see_stats_announcements?
    current_user && (current_user.gds_editor? || current_user.organisation_slug == 'office-for-national-statistics')
  end
  helper_method :user_can_see_stats_announcements?

  def restrict_access_to_gds_editors_and_ons_users
    forbidden! unless user_can_see_stats_announcements?
  end
end
