class Admin::CorporateInformationPagesController < Admin::EditionsController
  before_filter :find_organisation
  before_filter :find_corporate_information_page, only: [:edit, :update, :destroy]

  helper_method :cip_owning_organisation

  class FakeEditionFilter < Struct.new(:editions, :page_title, :show_stats, :hide_type)
  end

  def index
    params[:state] = 'active'
    paginator = @organisation.corporate_information_pages.order('corporate_information_page_type_id').page(1).per(100)
    @filter = FakeEditionFilter.new paginator, "Corporate information pages", false, true
  end

  def new
    build_corporate_information_page
  end

  def create
    @corporate_information_page = @organisation.build_corporate_information_page(new_edition_params)
    if @corporate_information_page.save
      redirect_to [:admin, @organisation, CorporateInformationPage], notice: "#{@corporate_information_page.title} created successfully"
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def show_or_edit_path
    if params[:save_and_continue].present?
      [:edit, :admin, @organisation, @edition]
    else
      admin_corporate_information_page_path(@edition)
    end
  end

  def destroy
    # Linking EditionOrganisation is deleted on destroy, meaning that title can
    # no longer be rendered, so calculate it beforehand.
    title = @corporate_information_page.title
    if @corporate_information_page.destroy
      redirect_to [:admin, @organisation], notice: "#{title} deleted successfully"
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def cip_owning_organisation
    @organisation
  end

private

  def edition_class
    CorporateInformationPage
  end

  def find_corporate_information_page
    @corporate_information_page = @organisation.corporate_information_pages.find(params[:id])
  end

  def build_corporate_information_page
    @corporate_information_page ||= @organisation.corporate_information_pages.build(edition_params)
  end

  def find_organisation
    @organisation =
      if params.has_key?(:organisation_id)
        Organisation.find(params[:organisation_id])
      elsif params.has_key?(:worldwide_organisation_id)
        WorldwideOrganisation.find(params[:worldwide_organisation_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def params_filters
    {state: 'active', type: "corporate_information_page", organisation: @organisation.id, hide_type: true, ordering: [:corporate_information_page_type_id, 'editions.state']}
  end

  def saved_confirmation_notice
    { notice: "#{@corporate_information_page.title} updated successfully" }
  end
end
