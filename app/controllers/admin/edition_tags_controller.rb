class Admin::EditionTagsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!

  def edit
    @topic_taxonomy = Taxonomy::TopicTaxonomy.new
    @tag_form = TaxonomyTagForm.load(@edition.content_id)
  end

  def update
    EditionTaxonLinkPatcher.new.call(
      content_id: @edition.content_id,
      selected_taxons:,
      previous_version: params["taxonomy_tag_form"]["previous_version"],
    )
    redirect_to admin_edition_path(@edition),
                notice: "Your topic tags have been saved."
  rescue GdsApi::HTTPConflict
    redirect_to edit_admin_edition_tags_path(@edition),
                alert: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end

  def find_edition
    edition = Edition.find(params[:edition_id])
    @edition = LocalisedModel.new(edition, edition.primary_locale)
  end

  def selected_taxons
    params["taxonomy_tag_form"].fetch("taxons", []).reject(&:blank?)
  end
end
