require 'test_helper'

class Api::WorldLocationPresenterTest < PresenterTestCase
  setup do
    @location = stub_record(:world_location, world_location_type: WorldLocationType::WorldLocation)
    @presenter = Api::WorldLocationPresenter.new(@location, @view_context)
    stubs_helper_method(:params).returns(format: :json)
  end

  test ".paginate returns a page presenter for the correct page of presented world locations" do
    stubs_helper_method(:params).returns(page: 1)
    page = [@location]
    Api::Paginator.stubs(:paginate).with([@location], page: 1).returns(page)

    paginated = Api::WorldLocationPresenter.paginate([@location], @view_context)

    assert_equal Api::PagePresenter, paginated.class
    assert_equal 1, paginated.page.size
    assert_equal Api::WorldLocationPresenter, paginated.page.first.class
    assert_equal @location, paginated.page.first.model
  end

  test 'links has a self link, pointing to the request-relative api location url' do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    self_link = @presenter.links.detect { |(url, attrs)| attrs['rel'] == 'self'}
    assert self_link
    url, attrs = *self_link
    assert_equal api_world_location_url(@location, host: 'test.host'), url
  end

  test "json includes request-relative api location url as id" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal api_world_location_url(@location, host: 'test.host'), @presenter.as_json[:id]
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

  test "json includes request-relative api organisations url as organisations id" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal api_world_location_worldwide_organisations_url(@location, host: 'test.host'), @presenter.as_json[:organisations][:id]
  end

  test "json includes public location url (anchored on organisations) organisations web_url" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal world_location_url(@location, host: 'govuk.example.com', anchor: 'organisations'), @presenter.as_json[:organisations][:web_url]
  end

end
