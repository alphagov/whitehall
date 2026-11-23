class Admin::StandardEditionNavigationsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :enforce_mini_site_feature_flag
  before_action :enforce_navigation_allowed
  before_action :set_child_editions

  def edit
    @navigation_items = @edition.navigation_edition.navigation_items
  end

  def update
    navigation_edition = @edition.navigation_edition
    visible_child_documents = @edition.child_documents.where(id: @child_editions.to_a.map(&:document_id))
    selected_document_ids = Array(params[:child_document_ids]).map(&:to_i).uniq
    selected_child_documents = visible_child_documents.where(id: selected_document_ids)

    if selected_child_documents.size != selected_document_ids.size
      @navigation_items = navigation_edition.navigation_items
      flash.now[:alert] = "You can only add child pages of this document to the navigation menu"
      return render :edit, status: :unprocessable_entity
    end

    navigation_edition.transaction do
      navigation_edition.navigation_items.where.not(child_document: selected_child_documents).destroy_all
      selected_child_documents.each { |child_document| navigation_edition.navigation_items.find_or_create_by!(child_document:) }
    end

    redirect_to navigation_admin_standard_edition_path(@edition), notice: "Navigation menu saved"
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
