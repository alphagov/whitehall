class Admin::CorporateInformationPagesController < Admin::EditionsController
  prepend_before_action :find_organisation
  layout :get_layout

  FakeEditionFilter = Struct.new(:editions, :page_title, :show_stats, :hide_type)

  def index
    params[:state] = "active" # Ensure that state column is displayed.
    @paginator = @organisation.corporate_information_pages.where("state != ?", "superseded").order("corporate_information_page_type_id").page(params["page"].to_i || 1).per(100)
    @filter = FakeEditionFilter.new @paginator, "Corporate information pages", false, true

    render_design_system(:index, :legacy_index)
  end

  def destroy
    # The title method relies on the presence of the organisation so we need to
    # stash it before the page is destroyed, as the join model between the page
    # and the organisation will no longer exist afterwards.
    title = @edition.title
    edition_deleter = Whitehall.edition_services.deleter(@edition)
    if edition_deleter.perform!
      redirect_to [:admin, @organisation, CorporateInformationPage], notice: "The document '#{title}' has been deleted"
    else
      redirect_to admin_edition_path(@edition), alert: edition_deleter.failure_reason
    end
  end

private

  def get_layout
    design_system_actions = %w[confirm_destroy show edit update new create]
    design_system_actions += %w[index] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def edition_class
    CorporateInformationPage
  end

  def new_edition
    @organisation.build_corporate_information_page(new_edition_params)
  end

  def find_organisation
    @organisation =
      if params.key?(:organisation_id)
        Organisation.friendly.find(params[:organisation_id])
      elsif params.key?(:worldwide_organisation_id)
        WorldwideOrganisation.friendly.find(params[:worldwide_organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def document_can_be_previously_published
    false
  end
end
