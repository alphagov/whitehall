class Admin::EditionWorldTagsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!

  def edit
    @world_taxonomy = Taxonomy::WorldTaxonomy.new
    @tag_form = WorldTaxonomyTagForm.load(@edition.content_id)
  end

  def update
    EditionWorldTaxonLinkPatcher.new.call(
      content_id: @edition.content_id,
      selected_taxons: selected_taxons,
      invisible_taxons: previously_selected_topic_taxons,
      previous_version: params["world_taxonomy_tag_form"]["previous_version"],
    )
    redirect_to admin_edition_path(@edition),
      notice: "The tags have been updated."
  rescue GdsApi::HTTPConflict
    redirect_to edit_admin_edition_world_tags_path(@edition),
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
    params["world_taxonomy_tag_form"].fetch("taxons", []).reject(&:blank?)
  end

  def previously_selected_topic_taxons
    topic_taxons = EditionTaxonsFetcher.new(@edition.content_id).fetch
    topic_taxons.map(&:content_id)
  end
end
