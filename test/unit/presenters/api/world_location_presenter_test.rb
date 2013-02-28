require 'test_helper'

class Api::WorldLocationPresenterTest < PresenterTestCase
  setup do
    @location = stub_record(:world_location, world_location_type: WorldLocationType::Country)
    @presenter = Api::WorldLocationPresenter.decorate(@location)
    stubs_helper_method(:params).returns(format: :json)
  end

  test ".paginate returns a decorated page of results" do
    stubs_helper_method(:params).returns(page: 1)
    page = stub('page')
    decorated_results = stub('decorated-results')
    Api::Paginator.stubs(:paginate).with([@location], page: 1).returns(page)
    Api::WorldLocationPresenter.stubs(:decorate).with(page).returns(decorated_results)
    assert_equal Api::WorldLocationPresenter.paginate([@location]), Api::PagePresenter.new(decorated_results)
  end

  test "json includes public api location url as id" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal api_world_location_url(@location, host: 'govuk.example.com'), @presenter.as_json[:id]
  end

  test "json includes location name as title" do
    @location.stubs(:name).returns('location-name')
    assert_equal 'location-name', @presenter.as_json[:title]
  end

  test "json includes location updated_at as updated_at" do
    now = Time.current
    @location.stubs(:updated_at).returns(now)
    assert_equal now, @presenter.as_json[:updated_at]
  end

  test "json includes iso2 code in details hash" do
    @location.stubs(:iso2).returns('zz')
    assert_equal 'zz', @presenter.as_json[:details][:iso2]
  end

  test "json includes slug in details hash" do
    @location.stubs(:slug).returns('location-slug')
    assert_equal 'location-slug', @presenter.as_json[:details][:slug]
  end

  test "json includes display type as format" do
    @location.stubs(:display_type).returns('location-display-type')
    assert_equal 'location-display-type', @presenter.as_json[:format]
  end

  test "json includes public location url as web_url" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal world_location_url(@location, host: 'govuk.example.com'), @presenter.as_json[:web_url]
  end

  test "json includes public api organisations url as organisations id" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal api_world_location_worldwide_organisations_url(@location, host: 'govuk.example.com'), @presenter.as_json[:organisations][:id]
  end

  test "json includes public location url (anchored on organisations) organisations web_url" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal world_location_url(@location, host: 'govuk.example.com', anchor: 'organisations'), @presenter.as_json[:organisations][:web_url]
  end

end
