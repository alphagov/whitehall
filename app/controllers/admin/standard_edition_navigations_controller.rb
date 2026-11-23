class Admin::StandardEditionNavigationsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :enforce_mini_site_feature_flag
  before_action :enforce_navigation_allowed
  before_action :set_child_editions

  def edit
    @navigation_items = @edition.navigation_edition.navigation_items
  end

private

  def find_edition
    edition = StandardEdition.find(params[:standard_edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end

  def enforce_mini_site_feature_flag
    return unless Admin::StandardEditionsController::MINI_SITE_DOCUMENT_TYPES.include?(@edition.configurable_document_type)
    return if Flipflop.enabled?(:mini_sites)

    raise Whitehall::Authority::Errors::PermissionDenied.new(action_name.to_sym, @edition)
  end

  def enforce_navigation_allowed
    render "admin/errors/not_found", status: :not_found unless @edition.allows_navigation?
  end

  def set_child_editions
    @child_editions = @edition.child_editions.select { |child_edition| can?(:see, child_edition) } if @edition.allows_child_documents?
  end
end
