require "test_helper"

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

  test "links has a self link, pointing to the request-relative api location url" do
    self_link = @presenter.links.detect { |(_url, attrs)| attrs["rel"] == "self" }
    assert self_link
    url, _attrs = *self_link
    assert_equal api_world_location_url(@location), url
  end

  test "json includes request-relative api location url as id" do
    assert_equal api_world_location_url(@location), @presenter.as_json[:id]
  end

  test "json includes location name as title" do
    @location.stubs(:name).returns("location-name")
    assert_equal "location-name", @presenter.as_json[:title]
  end

  test "json includes location updated_at as updated_at" do
    now = Time.zone.now
    @location.stubs(:updated_at).returns(now)
    assert_equal now, @presenter.as_json[:updated_at]
  end

  test "json includes iso2 code in details hash" do
    @location.stubs(:iso2).returns("zz")
    assert_equal "zz", @presenter.as_json[:details][:iso2]
  end

  test "json includes slug in details hash" do
    @location.stubs(:slug).returns("location-slug")
    assert_equal "location-slug", @presenter.as_json[:details][:slug]
  end

  test "json includes analytics_identifier in details hash" do
    @location.stubs(:analytics_identifier).returns("WL123")
    assert_equal "WL123", @presenter.as_json[:analytics_identifier]
  end

  test "json includes display type as format" do
    @location.stubs(:display_type).returns("location-display-type")
    assert_equal "location-display-type", @presenter.as_json[:format]
  end

  test "json includes content_id" do
    @location.stubs(:content_id).returns("world-location-content-id")
    assert_equal "world-location-content-id", @presenter.as_json[:content_id]
  end

  test "json includes public location url as web_url" do
    assert_equal Whitehall.url_maker.world_location_url(@location), @presenter.as_json[:web_url]
  end

  test "json includes request-relative api organisations url as organisations id" do
    assert_equal api_world_location_worldwide_organisations_url(@location, host: "test.host"), @presenter.as_json[:organisations][:id]
  end

  test "json includes public location url (anchored on organisations) organisations web_url" do
    assert_equal Whitehall.url_maker.world_location_url(@location, anchor: "organisations"), @presenter.as_json[:organisations][:web_url]
  end

  test "json includes Coronavirus RAG status when there is a Coronavirus RAG status" do
    @location.stubs(:coronavirus_rag_status).returns("red")
    assert_equal "red", @presenter.as_json[:england_coronavirus_travel][:covid_status]
  end

  test "json includes Coronavirus next RAG status information when there is a Coronavirus next RAG status" do
    @location.stubs(:coronavirus_rag_status).returns("green")
    @location.stubs(:coronavirus_next_rag_status).returns("red")
    rag_status_date = Time.zone.tomorrow.noon
    @location.stubs(:coronavirus_next_rag_applies_at).returns(rag_status_date)

    assert_equal "red", @presenter.as_json[:england_coronavirus_travel][:next_covid_status]
    assert_equal rag_status_date, @presenter.as_json[:england_coronavirus_travel][:next_covid_status_applies_at]
  end

  test "json includes Coronavirus RAG status out of date when Coronavirus RAG status is out of date" do
    @location.stubs(:coronavirus_rag_status).returns("red")
    @location.stubs(:coronavirus_status_out_of_date).returns(true)
    assert @presenter.as_json[:england_coronavirus_travel][:status_out_of_date]
  end
end
