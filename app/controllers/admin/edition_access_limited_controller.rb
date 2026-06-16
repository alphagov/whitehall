class Admin::EditionAccessLimitedController < Admin::BaseController
  include AccessLimitingConcern

  before_action :find_edition
  before_action :enforce_permissions!
  before_action :clean_organisation_params, only: %i[update]

  def edit; end

  def update
    editorial_remark = edition_params.delete(:editorial_remark)

    @edition.assign_attributes(edition_params.except(:access_limiting_organisation_ids, :access_limiting))
    @edition.access_limiting = access_limiting_param

    # Assign organisations to the in-memory edition for validation.
    # Actual persistence is deferred to @edition.save below.
    sync_access_limiting_organisations

    return render :edit unless access_limiting_organisations_valid?

    # Unset organisation options if switching away from organisation access limiting.
    # Must happen after validation so we don't wipe organisations on a failed save.
    clear_access_limiting_organisations_unless_organisations_selected if Flipflop.access_limiting_organisations_ui?

    unless changed?
      return redirect_to admin_editions_path, notice: "Access updated for #{@edition.title}"
    end

    if editorial_remark.blank?
      @edition.errors.add(:editorial_remark, t("errors.messages.blank"))
      return render :edit
    end

    if @edition.save
      PublishingApiDocumentRepublishingJob.perform_async(@edition.document_id, false)
      EditorialRemark.create!(
        edition: @edition,
        body: "Access options updated by GDS Admin: #{editorial_remark}",
        author: current_user,
        created_at: Time.zone.now,
        updated_at: Time.zone.now,
      )
      redirect_to admin_editions_path, notice: "Access updated for #{@edition.title}"
    else
      render :edit
    end
  end

private

  # TODO: Remove this when we remove the legacy access field
  def access_limiting_param
    return edition_params[:access_limiting] if %w[organisations none].include?(edition_params[:access_limiting])

    edition_params[:access_limiting] == "1" ? :organisations : :none
  end

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
        :access_limiting,
        :editorial_remark,
        {
          lead_organisation_ids: [],
          supporting_organisation_ids: [],
          access_limiting_organisation_ids: [],
        },
      )
  end

  def clean_organisation_params
    if edition_params[:lead_organisation_ids]
      edition_params[:lead_organisation_ids] =
        edition_params[:lead_organisation_ids].reject(&:blank?)
    end

    if edition_params[:supporting_organisation_ids]
      edition_params[:supporting_organisation_ids] =
        edition_params[:supporting_organisation_ids].reject(&:blank?)
    end
  end

  def changed?
    original = Edition.find(params[:id])

    access_limiting_changed = @edition.access_limiting != original.access_limiting
    access_limiting_organisations_changed =
      @edition.access_limiting_organisation_ids.sort != original.access_limiting_organisation_ids.sort
    lead_and_supporting_organisations_changed =
      @edition.organisation_association_enabled? &&
      @edition.edition_organisations != original.edition_organisations

    access_limiting_changed ||
      access_limiting_organisations_changed ||
      lead_and_supporting_organisations_changed
  end
end
