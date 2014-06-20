require 'test_helper'

class Api::DetailedGuidePresenterTest < PresenterTestCase
  setup do
    @organisation = stub_record(:organisation, organisation_type: OrganisationType.ministerial_department)
    @guide = stub_edition(:detailed_guide, organisations: [@organisation])
    @guide.stubs(:images).returns([])
    @guide.stubs(:published_related_detailed_guides).returns([])
    @guide.stubs(:organisations).returns([@organisation])
    @presenter = Api::DetailedGuidePresenter.new(@guide, @view_context)
    stubs_helper_method(:params).returns(format: :json)
  end

  test ".paginate returns a page presenter for the correct page of presented detailed guides" do
    stubs_helper_method(:params).returns(page: 1)
    page = [@guide]
    Api::Paginator.stubs(:paginate).with([@guide], page: 1).returns(page)

    paginated = Api::DetailedGuidePresenter.paginate([@guide], @view_context)

    assert_equal Api::PagePresenter, paginated.class
    assert_equal 1, paginated.page.size
    assert_equal Api::DetailedGuidePresenter, paginated.page.first.class
    assert_equal @guide, paginated.page.first.model
  end

  test 'links has a self link, pointing to the public API url' do
    self_link = @presenter.links.detect { |(url, attrs)| attrs['rel'] == 'self'}
    assert self_link
    url, attrs = *self_link
    assert_equal api_detailed_guide_url(@guide.document), url
  end

  test "json includes document title" do
    @guide.stubs(:title).returns('guide-title')
    assert_equal 'guide-title', @presenter.as_json[:title]
  end

  test "json includes the public API url as id" do
    assert_equal api_detailed_guide_url(@guide.document), @presenter.as_json[:id]
  end

  test "json includes public guide url as web_url" do
    assert_equal Whitehall.url_maker.detailed_guide_url(@guide.document), @presenter.as_json[:web_url]
  end

  test "json includes the document body (without govspeak wrapper div) as html" do
    @guide.stubs(:body).returns("govspeak-body")
    assert_equivalent_html '<p>govspeak-body</p>', @presenter.as_json[:details][:body]
  end

  test "json includes related detailed guides as related" do
    related_guide = stub_edition(:detailed_guide, organisations: [@organisation])
    @guide.stubs(:published_related_detailed_guides).returns([related_guide])
    guide_json = {
      id: api_detailed_guide_url(related_guide.document),
      title: related_guide.title,
      web_url: Whitehall.url_maker.detailed_guide_url(related_guide.document)
    }
    assert_equal [guide_json], @presenter.as_json[:related]
  end

  test "json includes organisations as tags" do
    guide_json = {
      title: @organisation.name,
      id: organisation_url(@organisation, format: :json),
      web_url: Whitehall.url_maker.organisation_url(@organisation),
      details: {
        type: 'organisation',
        short_description: @organisation.acronym
      }
    }
    assert_equal [guide_json], @presenter.as_json[:tags]
  end

  test "json includes format name" do
    assert_equal "detailed guidance", @presenter.as_json[:format]
  end
end
