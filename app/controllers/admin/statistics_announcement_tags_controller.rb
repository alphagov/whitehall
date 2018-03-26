class Admin::StatisticsAnnouncementTagsController < Admin::BaseController
  before_action :find_statistics_announcement
  before_action :enforce_permissions!

  def edit
    @govuk_taxonomy = Taxonomy::GovukTaxonomy.new
    @tag_form = TaxonomyTagForm.load(@statistics_announcement.content_id)
  end

  def update
    EditionTaxonLinkPatcher.new.call(
      model: @statistics_announcement,
      selected_taxons: selected_taxons,
      invisible_taxons: invisible_taxons,
      previous_version: params["taxonomy_tag_form"]["previous_version"],
    )

    redirect_to admin_statistics_announcement_path(@statistics_announcement),
      notice: "The tags have been updated."
  rescue GdsApi::HTTPConflict
    redirect_to edit_admin_statistics_announcement_tags_path(@statistics_announcement),
      alert: "Somebody changed the tags before you could. Your changes have not been saved."
  end

private

  def enforce_permissions!
    unless @statistics_announcement.can_be_tagged_to_taxonomy?
      raise Whitehall::Authority::Errors::PermissionDenied.new(:update, @statistics_announcement)
    end

    enforce_permission!(:update, @statistics_announcement)
  end

  def find_statistics_announcement
    @statistics_announcement = StatisticsAnnouncement.friendly.find(params[:statistics_announcement_id])
  end

  def selected_taxons
    params["taxonomy_tag_form"].fetch("taxons", []).reject(&:blank?)
  end

  def invisible_taxons
    params["taxonomy_tag_form"].fetch("invisible_taxons", "").split(",")
  end
end
