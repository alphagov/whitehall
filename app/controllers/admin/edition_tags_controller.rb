class Admin::EditionTagsController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!
  before_action :forbid_editing_of_locked_documents
  layout :get_layout

  def edit
    @topic_taxonomy = Taxonomy::TopicTaxonomy.new
    @tag_form = TaxonomyTagForm.load(@edition.content_id)

    render(preview_design_system_user? ? "edit" : "edit_legacy")
  end

  def update
    EditionTaxonLinkPatcher.new.call(
      content_id: @edition.content_id,
      selected_taxons: selected_taxons,
      invisible_taxons: invisible_taxons + previously_selected_world_taxons,
      previous_version: params["taxonomy_tag_form"]["previous_version"],
    )

    # Only automatically add legacy associations if this is new
    # content, to avoid repeatedly adding legacy associations if
    # they've been manually removed
    unless @edition.published?
      legacy_associations_changed = TaxonsToLegacyAssociationsTagging.new.call(
        edition: @edition,
        user: current_user,
        selected_taxons: selected_taxons,
      )

      flash[:legacy_associations_changed] = legacy_associations_changed
    end

    redirect_to redirect_path,
                notice: "The tags have been updated."
  rescue GdsApi::HTTPConflict
    redirect_to edit_admin_edition_tags_path(@edition),
                alert: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private

  def get_layout
    return "admin" unless preview_design_system_user?

    case action_name
    when "edit"
      "design_system"
    else
      "admin"
    end
  end

  def redirect_path
    if params[:save] || current_user.can_redirect_to_summary_page?
      admin_edition_path(@edition)
    else
      edit_admin_edition_legacy_associations_path(@edition, return: :tags)
    end
  end

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

  def invisible_taxons
    params["taxonomy_tag_form"].fetch("invisible_taxons", "").split(",")
  end

  def previously_selected_world_taxons
    world_taxons = EditionTaxonsFetcher.new(@edition.content_id).fetch_world_taxons
    world_taxons.map(&:content_id)
  end
end
