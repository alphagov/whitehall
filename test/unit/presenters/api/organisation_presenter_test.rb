require 'test_helper'

class Api::OrganisationPresenterTest < PresenterTestCase
  setup do
    @organisation = stub_record(:organisation, organisation_type: OrganisationType.ministerial_department)
    @organisation.stubs(:parent_organisations).returns([])
    @organisation.stubs(:child_organisations).returns([])
    @organisation.stubs(:superseded_organisations).returns([])
    @organisation.stubs(:superseding_organisations).returns([])
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
    self_link = @presenter.links.detect { |(_url, attrs)| attrs['rel'] == 'self' }
    assert self_link
    url, _attrs = *self_link
    assert_equal api_organisation_url(@organisation), url
  end

  test "json includes request-relative api organisation url as id" do
    assert_equal api_organisation_url(@organisation), @presenter.as_json[:id]
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

  test "json includes acronym in details hash as abbreviation" do
    @organisation.stubs(:acronym).returns('decc')
    assert_equal 'decc', @presenter.as_json[:details][:abbreviation]
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

  test "json includes govuk_closed_status in details hash" do
    @organisation.stubs(:govuk_closed_status).returns("split")
    assert_equal "split", @presenter.as_json[:details][:govuk_closed_status]
  end

  test "json includes analytics_identifier in details hash" do
    @organisation.stubs(:analytics_identifier).returns("O123")
    assert_equal "O123", @presenter.as_json[:analytics_identifier]
  end

  test "json includes human organisation type as format" do
    assert_equal 'Ministerial department', @presenter.as_json[:format]
  end

  test "json includes public organisation url as web_url" do
    assert_equal Whitehall.url_maker.organisation_url(@organisation), @presenter.as_json[:web_url]
  end

  test "json includes request-relative api parent organisations" do
    parent = stub_record(:organisation)
    @organisation.stubs(:parent_organisations).returns([parent])
    assert_equal api_organisation_url(parent), @presenter.as_json[:parent_organisations].first[:id]
    assert_equal Whitehall.url_maker.organisation_url(parent), @presenter.as_json[:parent_organisations].first[:web_url]
  end

  test "json includes request-relative api child organisations" do
    child = stub_record(:organisation)
    @organisation.stubs(:child_organisations).returns([child])
    assert_equal api_organisation_url(child), @presenter.as_json[:child_organisations].first[:id]
    assert_equal Whitehall.url_maker.organisation_url(child), @presenter.as_json[:child_organisations].first[:web_url]
  end

  test "json includes superseding_organisations and superseded_organisations" do
    superseded = stub_record(:organisation)
    superseding = stub_record(:organisation)
    @organisation.stubs(:superseded_organisations).returns([superseded])
    @organisation.stubs(:superseding_organisations).returns([superseding])

    json = @presenter.as_json

    assert_equal api_organisation_url(superseded), json[:superseded_organisations].first[:id]
    assert_equal api_organisation_url(superseding), json[:superseding_organisations].first[:id]
  end
end
