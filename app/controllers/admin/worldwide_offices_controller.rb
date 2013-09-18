class Admin::WorldwideOfficesController < Admin::BaseController
  before_filter :find_worldwide_organisation
  before_filter :find_worldwide_office, only: [:edit, :update, :destroy, :add_to_home_page, :remove_from_home_page]
  before_filter :destroy_blank_contact_numbers, only: [:create, :update]

  def index
  end

  def new
    @worldwide_office = @worldwide_organisation.offices.build
    @worldwide_office.build_contact
    @worldwide_office.contact.contact_numbers.build
  end

  def edit
    @worldwide_office.contact.contact_numbers.build unless @worldwide_office.contact.contact_numbers.any?
  end

  def update
    params[:worldwide_office] = {service_ids: []}.merge(params[:worldwide_office])
    @worldwide_office.update_attributes(params[:worldwide_office])
    if @worldwide_office.save
      handle_show_on_home_page_param
      redirect_to [:admin, @worldwide_organisation, WorldwideOffice]
    else
      render :edit
    end
  end

  def create
    @worldwide_office = @worldwide_organisation.offices.build(params[:worldwide_office])
    if @worldwide_office.save
      handle_show_on_home_page_param
      redirect_to [:admin, @worldwide_organisation, WorldwideOffice]
    else
      render :edit
    end
  end

  def destroy
    if @worldwide_office.destroy
      redirect_to [:admin, @worldwide_organisation, WorldwideOffice]
    else
      render :edit
    end
  end

  extend Admin::HomePageListController
  is_home_page_list_controller_for :offices,
    item_type: WorldwideOffice,
    contained_by: :worldwide_organisation,
    redirect_to: ->(container, item) { [:admin, container, WorldwideOffice] },
    params_name: :worldwide_office
  def home_page_list_item
    @worldwide_office
  end

private
  def find_worldwide_organisation
    @worldwide_organisation ||= WorldwideOrganisation.find(params[:worldwide_organisation_id])
  end

  def find_worldwide_office
    @worldwide_office = @worldwide_organisation.offices.find(params[:id])
  end

  def destroy_blank_contact_numbers
    contact_number_params.each do |index, attributes|
      if attributes.except(:id).values.all?(&:blank?)
        attributes[:_destroy] = "1"
      end
    end
  end

  def contact_number_params
    (params[:worldwide_office][:contact_attributes] || {})[:contact_numbers_attributes] || []
  end

end
