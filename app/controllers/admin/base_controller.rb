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
      puts "You can't #{action} that #{subject.inspect}"
      forbidden!
    end
  end

  private

  def enforcer_for(subject)
    actor = current_user || User.new
    enforcer = Whitehall::Authority::Enforcer.new(actor, subject)
  end

  def forbidden!
    render "admin/editions/forbidden", status: 403
  end
end
