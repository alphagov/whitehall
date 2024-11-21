class Admin::EditionAccessLimitedController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :clean_organisation_params, only: %i[update]

  def edit; end

  def update
    editorial_remark = edition_params.delete(:editorial_remark)
    @edition.assign_attributes(edition_params)

    if changed?
      if editorial_remark.blank?
        @edition.errors.add(:editorial_remark, "can't be blank")

        render :edit
      else
        @edition.save!
        PublishingApiDocumentRepublishingWorker.perform_async(@edition.document_id)

        EditorialRemark.create!(
          edition: @edition,
          body: "Access options updated by GDS Admin: #{editorial_remark}",
          author: current_user,
          created_at: Time.zone.now,
          updated_at: Time.zone.now,
        )

        redirect_to admin_editions_path, notice: "Access updated for #{@edition.title}"
      end
    else
      redirect_to admin_editions_path, notice: "Access updated for #{@edition.title}"
    end
  end

private

  def find_edition
    @edition = Edition.find(params[:id])
  end

  def enforce_permissions!
    enforce_permission!(:perform_administrative_tasks, Edition)
  end

  def edition_params
    @edition_params ||= params
    .fetch(:edition, {})
    .permit(
      :access_limited,
      :editorial_remark,
      {
        lead_organisation_ids: [],
        supporting_organisation_ids: [],
      },
    )
  end

  def clean_organisation_params
    if edition_params[:lead_organisation_ids]
      edition_params[:lead_organisation_ids] = edition_params[:lead_organisation_ids].reject(&:blank?)
    end
    if edition_params[:supporting_organisation_ids]
      edition_params[:supporting_organisation_ids] = edition_params[:supporting_organisation_ids].reject(&:blank?)
    end
  end

  def changed?
    if @edition.can_be_related_to_organisations?
      @edition.changed? ||
        @edition.lead_organisation_ids.map(&:to_s) != edition_params[:lead_organisation_ids] ||
        @edition.supporting_organisations.map(&:id).map(&:to_s) != edition_params[:supporting_organisation_ids]
    else
      @edition.changed?
    end
  end
end
