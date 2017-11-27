class Admin::EditionTagsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!

  def edit
    @govuk_taxonomy = Taxonomy::GovukTaxonomy.new
    @tag_form = TaxonomyTagForm.load(@edition.content_id)
  end

  def update
    @tag_form = TaxonomyTagForm.new(
      content_id: @edition.content_id,
      selected_taxons: selected_taxons,
      invisible_taxons: invisible_taxons,
      previous_version: params["taxonomy_tag_form"]["previous_version"],
      all_taxons: Taxonomy::GovukTaxonomy.new.all_taxons
    )

    @tag_form.publish!
    redirect_to admin_edition_path(@edition),
      notice: "The tags have been updated."
  rescue GdsApi::HTTPConflict
    redirect_to edit_admin_edition_tags_path(@edition),
      alert: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private

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

  def selected_taxons
    params["taxonomy_tag_form"].fetch("taxons", []).reject(&:blank?)
  end

  def invisible_taxons
    params["taxonomy_tag_form"].fetch("invisible_draft_taxons", "").split(",")
  end
end
