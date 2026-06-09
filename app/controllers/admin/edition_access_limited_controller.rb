class Admin::EditionAccessLimitedController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :clean_organisation_params, only: %i[update]

  def edit
    if Flipflop.access_limiting_organisations_ui? &&
        @edition.access_limited_by_default? &&
        @edition.access_limiting_organisations.empty?
      @edition.access_limiting_organisations = @edition.lead_organisations
    end
  end

  def update
    editorial_remark = edition_params.delete(:editorial_remark)

    permitted = edition_params.except(
      :access_limiting_organisation_ids,
      :access_limiting_radio,
      :access_limited,
    )
    @edition.assign_attributes(permitted)

    if Flipflop.access_limiting_organisations_ui?
      case edition_params[:access_limiting_radio]
      when "no_access_limiting"
        @edition.access_limited = false
      when "organisation_access_limiting"
        @edition.access_limited = true
      end

      @edition.access_limiting_organisation_ids =
        Array(edition_params[:access_limiting_organisation_ids]).reject(&:blank?)
    else
      @edition.access_limited = edition_params[:access_limited] == "1"
    end

    something_changed = changed?

    unless @edition.valid?
      render :edit
      return
    end

    if something_changed
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
        :access_limiting_radio,
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
    if @edition.organisation_association_enabled?
      @edition.changed? ||
        @edition.edition_organisations != original_edition.edition_organisations ||
        @edition.access_limiting_organisation_ids.sort != original_edition.access_limiting_organisation_ids.sort
    else
      @edition.changed? ||
        @edition.access_limiting_organisation_ids.sort != original_edition.access_limiting_organisation_ids.sort
    end
  end
end
