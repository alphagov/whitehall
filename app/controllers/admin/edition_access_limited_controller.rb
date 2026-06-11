class Admin::EditionAccessLimitedController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :clean_organisation_params, only: %i[update]

  def edit; end

  def update
    editorial_remark = edition_params.delete(:editorial_remark)

    permitted = edition_params.except(
      :access_limiting_organisation_ids,
      :access_limiting,
    )
    @edition.assign_attributes(permitted)

    @edition.access_limiting = access_limiting_param

    if Flipflop.access_limiting_organisations_ui?
      @edition.access_limiting_organisation_ids =
        Array(edition_params[:access_limiting_organisation_ids]).reject(&:blank?)
    end

    access_limiting_attributes_changed = changed?

    unless @edition.valid?
      render :edit
      return
    end

    if access_limiting_attributes_changed
      if editorial_remark.blank?
        @edition.errors.add(:editorial_remark, t("errors.messages.blank"))
        render :edit
        return
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
    else
      redirect_to admin_editions_path, notice: "Access updated for #{@edition.title}"
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

  def original_edition
    @original_edition ||= Edition.find(params[:id])
  end

  def changed?
    original = original_edition

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
