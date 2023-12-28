class Admin::EditionableSocialMediaAccountsController < Admin::BaseController
  before_action :find_edition

  def index; end

private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end
end
