class Admin::EditionTagsController < Admin::BaseController
  before_filter :find_edition
  before_filter :enforce_permissions!
  before_filter :limit_edition_access!

  def edit
    @edition_tag_form = EditionTaxonomyTagForm.load(@edition.content_id)
    @published_taxonomies = Taxonomy.all_taxonomy_trees
  end

  def update
    @edition_tag_form = EditionTaxonomyTagForm.new(
      edition_content_id: @edition.content_id,
      selected_taxons: params["edition_taxonomy_tag_form"].fetch("taxons", []).reject(&:blank?),
      previous_version: params["edition_taxonomy_tag_form"]["previous_version"]
    )

    @edition_tag_form.publish!
    redirect_to admin_edition_path(@edition),
      notice: "The tags have been updated."
  rescue GdsApi::HTTPConflict
    redirect_to edit_admin_edition_tags_path(@edition),
      alert: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private

  def redirect_back
    if request.env["HTTP_REFERER"].blank?
      redirect_to admin_root_path
    else
      redirect_to :back
    end
  end

  def enforce_permissions!
    unless @edition.can_be_tagged_to_taxonomy?
      raise Whitehall::Authority::Errors::PermissionDenied.new(:update, @edition)
    end

    enforce_permission!(:update, @edition)
  end

  def find_edition
    edition = Edition.find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end
end
