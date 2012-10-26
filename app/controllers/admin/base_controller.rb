class Admin::BaseController < ApplicationController
  include Admin::EditionRoutesHelper

  layout 'admin'
  prepend_before_filter :authenticate_user!
  before_filter :require_signin_permission!
  before_filter :skip_slimmer

  def limit_edition_access!
    unless @edition.accessible_by?(current_user)
      render :forbidden, status: 403
    end
  end
end
