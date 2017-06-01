class WorldwideOrganisationsController < PublicFacingController
  include CacheControlHelper
  enable_request_formats show: :json
  before_action :load_worldwide_organisation
  before_action :setup_a_b_test

  respond_to :html, :json

  def show
    redirect_if_required_for_ab_test
    respond_to do |format|
      format.html do
        set_expiry 5.minutes
        @world_locations = @worldwide_organisation.world_locations
        @main_office = @worldwide_organisation.main_office if @worldwide_organisation.main_office
        @home_page_offices = @worldwide_organisation.home_page_offices
        @primary_role = primary_role
        @other_roles = ([secondary_role] + office_roles).compact
        set_meta_description(@worldwide_organisation.summary)
        set_slimmer_organisations_header([@worldwide_organisation] + @worldwide_organisation.sponsoring_organisations)
        set_slimmer_world_locations_header(@world_locations)
      end
      format.json { redirect_to api_worldwide_organisation_path(@worldwide_organisation, format: :json) }
    end
  end

  def show_b_variant
    @world_location = WorldLocation.with_translations(I18n.locale).find(params[:world_location_id])
    @main_office = @worldwide_organisation.main_office if @worldwide_organisation.main_office
    @home_page_offices = @worldwide_organisation.home_page_offices
    @embassy_data = embassy_test_data(params[:id])
    @primary_role = primary_role
    @other_roles = ([secondary_role] + office_roles).compact

    set_meta_description(@worldwide_organisation.summary)
    set_slimmer_organisations_header([@worldwide_organisation] + @worldwide_organisation.sponsoring_organisations)

    if b_variant? && @embassy_data
      if locale_is_en?
        render template: 'embassies/show'
      else
        redirect_and_exit_group_if_non_en_locale
      end
    else
      redirect_to @worldwide_organisation
    end
  end

private

  def redirect_and_exit_group_if_non_en_locale
    redirect_to worldwide_organisation_path(
      @worldwide_organisation,
      "ABTest-WorldwidePublishingTaxonomy" => "A",
      locale: I18n.locale
    )
  end

  def redirect_if_required_for_ab_test
    if b_variant? &&
        worldwide_test_helper.is_under_test?(@worldwide_organisation) &&
        locale_is_en?
      redirect_to worldwide_test_helper.location_for(@worldwide_organisation)
    end
  end

  def worldwide_test_helper
    @helper ||= WorldwideAbTestHelper.new
  end

  def locale_is_en?
    I18n.locale == :en
  end

  def load_worldwide_organisation
    @worldwide_organisation = WorldwideOrganisation.with_translations(I18n.locale).find(params[:id])
  end

  def primary_role
    RolePresenter.new(@worldwide_organisation.primary_role, view_context) if @worldwide_organisation.primary_role
  end

  def secondary_role
    RolePresenter.new(@worldwide_organisation.secondary_role, view_context) if @worldwide_organisation.secondary_role
  end

  def office_roles
    @worldwide_organisation.office_staff_roles.map { |office_staff| RolePresenter.new(office_staff, view_context) }
  end

  def test_helper_content
    worldwide_test_helper.content_for(@world_location.slug) if worldwide_test_helper.has_content_for?(@world_location.slug)
  end

  def embassies_test_data
    test_helper_content["embassies"] if test_helper_content
  end

  def embassy_test_data(embassy)
    embassies_test_data[embassy].first if embassies_test_data && embassies_test_data[embassy]
  end

  def setup_a_b_test
    ab_test = GovukAbTesting::AbTest.new("WorldwidePublishingTaxonomy", dimension: 45)
    @requested_variant = ab_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)
  end

  def b_variant?
    @requested_variant.variant_b?
  end
end
