class Admin::EditionAccessLimitedController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :clean_organisation_params, only: %i[update]

  def edit
    @edition.prefill_default_access_limiting_organisations
  end

  def update
    editorial_remark = edition_params.delete(:editorial_remark)

    @edition.assign_attributes(edition_params.except(:access_limiting_organisation_ids, :access_limiting))
    @edition.access_limiting = access_limiting_param
    assign_access_limiting_organisations

    return render :edit unless access_limiting_organisations_valid?
    unset_organisation_access_limit_options if Flipflop.access_limiting_organisations_ui?

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

  def assign_access_limiting_organisations
    return unless Flipflop.access_limiting_organisations_ui?
    return unless submitted_access_limiting_organisation_ids.any?

    @edition.access_limiting_organisations = Organisation.where(id: submitted_access_limiting_organisation_ids)
  end

  def access_limiting_organisations_valid?
    return true unless Flipflop.access_limiting_organisations_ui?
    return true unless submitted_access_limiting_organisation_ids.empty?
    return true unless @edition.access_limiting_organisations?

    @edition.errors.add(:access_limiting_organisation_ids,
                        "must include at least one organisation when access limiting is enabled")

    false
  end

  def destruct_old_access_limiting_organisations
    return unless submitted_access_limiting_organisation_ids.empty?

    @edition.edition_access_limiting_organisations.each(&:mark_for_destruction)
  end

  def unset_organisation_access_limit_options
    @edition.access_limiting_organisation_ids = [] unless @edition.access_limiting == "organisations"
    destruct_old_access_limiting_organisations
  end

  def submitted_access_limiting_organisation_ids
    @submitted_org_ids ||= Array(edition_params[:access_limiting_organisation_ids]).reject(&:blank?)
  end

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
    # Lead/supporting organisations are only relevant when the edition supports them.
    lead_and_supporting_organisations_changed =
      @edition.organisation_association_enabled? &&
      @edition.edition_organisations != original.edition_organisations

    access_limiting_changed ||
      access_limiting_organisations_changed ||
      lead_and_supporting_organisations_changed
  end
end
