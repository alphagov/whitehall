class Admin::WorldwideOfficesController < Admin::BaseController
  before_filter :find_worldwide_office, only: [:edit, :update, :destroy, :add_to_home_page, :remove_from_home_page]
  before_filter :destroy_blank_contact_numbers, only: [:create, :update]
  before_filter :extract_show_on_home_page_param, only: [:create, :update]

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
      handle_show_on_home_page_param
      redirect_to [:admin, worldwide_organisation, WorldwideOffice]
    else
      render :edit
    end
  end

  def create
    @worldwide_office = worldwide_organisation.offices.build(params[:worldwide_office])
    if @worldwide_office.save
      handle_show_on_home_page_param
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

  def remove_from_home_page
    @show_on_home_page = '0'
    handle_show_on_home_page_param
    redirect_to [:admin, worldwide_organisation, WorldwideOffice], notice: %{"#{@worldwide_office.title}" removed from home page successfully}
  end

  def add_to_home_page
    @show_on_home_page = '1'
    handle_show_on_home_page_param
    redirect_to [:admin, worldwide_organisation, WorldwideOffice], notice: %{"#{@worldwide_office.title}" added to home page successfully}
  end

  def reorder_for_home_page
    reordered_offices = extract_worldwide_offices_from_ordering_params(params[:ordering] || {})
    worldwide_organisation.reorder_offices_on_home_page!(reordered_offices)
    redirect_to [:admin, worldwide_organisation, WorldwideOffice], notice: %{Offices on home page reordered successfully}
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

  def extract_show_on_home_page_param
    @show_on_home_page = params[:worldwide_office].delete(:show_on_home_page)
  end

  def handle_show_on_home_page_param
    if @show_on_home_page.present?
      if @show_on_home_page == '1'
        worldwide_organisation.add_office_to_home_page!(@worldwide_office)
      elsif @show_on_home_page == '0'
        worldwide_organisation.remove_office_from_home_page!(@worldwide_office)
      end
    end
  end

  def extract_worldwide_offices_from_ordering_params(ids_and_orderings)
    ids_and_orderings.
      # convert to useful forms
      map {|worldwide_office_id, ordering| [WorldwideOffice.find_by_id(worldwide_office_id), ordering.to_i] }.
      # sort by ordering
      sort_by { |_, ordering| ordering }.
      # discard ordering
      map {|worldwide_office, _| worldwide_office }.
      # reject any blank worldwide offices
      compact
  end

end
