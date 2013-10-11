require 'test_helper'

class Api::OrganisationPresenterTest < PresenterTestCase
  setup do
    @organisation = stub_record(:organisation, organisation_type: OrganisationType.ministerial_department)
    @organisation.stubs(:parent_organisations).returns([])
    @organisation.stubs(:child_organisations).returns([])
    @presenter = Api::OrganisationPresenter.new(@organisation, @view_context)
    stubs_helper_method(:params).returns(format: :json)
  end

  test ".paginate returns a page presenter for the correct page of presented organisations" do
    stubs_helper_method(:params).returns(page: 1)
    page = [@organisation]
    Api::Paginator.stubs(:paginate).with([@organisation], page: 1).returns(page)

    paginated = Api::OrganisationPresenter.paginate([@organisation], @view_context)

    assert_equal Api::PagePresenter, paginated.class
    assert_equal 1, paginated.page.size
    assert_equal Api::OrganisationPresenter, paginated.page.first.class
    assert_equal @organisation, paginated.page.first.model
  end

  test 'links has a self link, pointing to the request-relative api organisation url' do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    self_link = @presenter.links.detect { |(url, attrs)| attrs['rel'] == 'self'}
    assert self_link
    url, attrs = *self_link
    assert_equal api_organisation_url(@organisation, host: 'test.host'), url
  end

  test "json includes request-relative api organisation url as id" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal api_organisation_url(@organisation, host: 'test.host'), @presenter.as_json[:id]
  end

  test "json includes organisation name as title" do
    @organisation.stubs(:name).returns('organisation-name')
    assert_equal 'organisation-name', @presenter.as_json[:title]
  end

  test "json includes organisation updated_at as updated_at" do
    now = Time.current
    @organisation.stubs(:updated_at).returns(now)
    assert_equal now, @presenter.as_json[:updated_at]
  end

  test "json includes acronym in details hash" do
    @organisation.stubs(:acronym).returns('decc')
    assert_equal 'decc', @presenter.as_json[:details][:acronym]
  end

  test "json includes slug in details hash" do
    @organisation.stubs(:slug).returns('organisation-slug')
    assert_equal 'organisation-slug', @presenter.as_json[:details][:slug]
  end

  test "json includes closed_at in details hash" do
    @organisation.stubs(:closed_at).returns(2.days.ago)
    assert_equal 2.days.ago, @presenter.as_json[:details][:closed_at]
  end

  test "json includes govuk_status in details hash" do
    @organisation.stubs(:govuk_status).returns("live")
    assert_equal "live", @presenter.as_json[:details][:govuk_status]
  end

  test "json includes human organisation type as format" do
    assert_equal 'Ministerial department', @presenter.as_json[:format]
  end

  test "json includes public organisation url as web_url" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    assert_equal organisation_url(@organisation, host: 'govuk.example.com'), @presenter.as_json[:web_url]
  end

  test "json includes request-relative api parent organisations" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    parent = stub_record(:organisation)
    @organisation.stubs(:parent_organisations).returns([parent])
    assert_equal api_organisation_url(parent, host: 'test.host'), @presenter.as_json[:parent_organisations].first[:id]
    assert_equal organisation_url(parent, host: 'govuk.example.com'), @presenter.as_json[:parent_organisations].first[:web_url]
  end

  test "json includes request-relative api child organisations" do
    Whitehall.stubs(:public_host_for).returns('govuk.example.com')
    child = stub_record(:organisation)
    @organisation.stubs(:child_organisations).returns([child])
    assert_equal api_organisation_url(child, host: 'test.host'), @presenter.as_json[:child_organisations].first[:id]
    assert_equal organisation_url(child, host: 'govuk.example.com'), @presenter.as_json[:child_organisations].first[:web_url]
  end
end
