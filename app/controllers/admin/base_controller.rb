class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper

  layout 'admin'
  prepend_before_filter :authenticate_user!
  before_filter :require_signin_permission!
  before_filter :skip_slimmer

  def limit_edition_access!
    forbidden! unless @edition.accessible_by?(current_user)
  end

  def require_fatality_handling_permission!
    forbidden! unless current_user.can_handle_fatalities?
  end

  def require_import_permission!
    authorise_user!(User::Permissions::IMPORT)
  end

  def can?(action, subject)
    enforcer_for(subject).can?(action)
  end
  helper_method :can?

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

  def enforcer_for(subject)
    actor = current_user || User.new
    Whitehall::Authority::Enforcer.new(actor, subject)
  end

  def forbidden!
    render "admin/editions/forbidden", status: 403
  end
end
