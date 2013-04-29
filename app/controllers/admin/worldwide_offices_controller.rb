class Admin::WorldwideOfficesController < Admin::BaseController
  before_filter :find_worldwide_office, only: [:edit, :update, :destroy]
  before_filter :destroy_blank_contact_numbers, only: [:create, :update]

  def index
    worldwide_organisation
  end

  def new
    @worldwide_office = worldwide_organisation.offices.build
    @worldwide_office.build_contact
    @worldwide_office.contact.contact_numbers.build
  end

  def edit
    @worldwide_office.contact.contact_numbers.build unless @worldwide_office.contact.contact_numbers.any?
  end

  def update
    @worldwide_office.update_attributes(params[:worldwide_office])
    if @worldwide_office.save
      redirect_to [:admin, worldwide_organisation, WorldwideOffice]
    else
      render :edit
    end
  end

  def create
    @worldwide_office = worldwide_organisation.offices.build(params[:worldwide_office])
    if @worldwide_office.save
      redirect_to [:admin, worldwide_organisation, WorldwideOffice]
    else
      render :edit
    end
  end

  def destroy
    if @worldwide_office.destroy
      redirect_to [:admin, worldwide_organisation, WorldwideOffice]
    else
      render :edit
    end
  end

private
  def worldwide_organisation
    @worldwide_organisation ||= WorldwideOrganisation.find(params[:worldwide_organisation_id])
  end

  def find_worldwide_office
    @worldwide_office = worldwide_organisation.offices.find(params[:id])
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
