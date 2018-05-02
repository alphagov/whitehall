class Admin::EditionLegacyAssociationsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!

  def edit

  end

private
  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end
end
