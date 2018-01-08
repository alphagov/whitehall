require 'test_helper'

class Api::GovernmentPresenterTest < PresenterTestCase
  setup do
    @government = stub_record(:government, slug: 'old-gov')
    @presenter = Api::GovernmentPresenter.new(@government, @view_context)
    stubs_helper_method(:params).returns(format: :json)
  end

  test ".paginate returns a page presenter for the correct page of presented governments" do
    stubs_helper_method(:params).returns(page: 1)
    page = [@government]
    Api::Paginator.stubs(:paginate).with([@government], page: 1).returns(page)

    paginated = Api::GovernmentPresenter.paginate([@government], @view_context)

    assert_equal Api::PagePresenter, paginated.class
    assert_equal 1, paginated.page.size
    assert_equal Api::GovernmentPresenter, paginated.page.first.class
    assert_equal @government, paginated.page.first.model
  end

  test 'links has a self link, pointing to the request-relative api government url' do
    self_link = @presenter.links.detect { |(_url, attrs)| attrs['rel'] == 'self' }
    assert self_link
    url, attrs = *self_link
    assert_equal api_government_url(@government.slug), url
  end

  test "json includes request-relative api government url as id" do
    assert_equal api_government_url(@government.slug), @presenter.as_json[:id]
  end

  test "json includes government name as title" do
    @government.stubs(:name).returns('government-name')
    assert_equal 'government-name', @presenter.as_json[:title]
  end

  test "json includes government start_date and end_date in details hash" do
    end_date = Time.current.to_date
    start_date = (Time.current - 2.days).to_date
    @government.stubs(:start_date).returns(start_date)
    @government.stubs(:end_date).returns(end_date)
    assert_equal start_date, @presenter.as_json[:details][:start_date]
    assert_equal end_date, @presenter.as_json[:details][:end_date]
  end
end
