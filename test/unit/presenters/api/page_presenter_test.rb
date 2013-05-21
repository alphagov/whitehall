require 'test_helper'

class Api::PagePresenterTest < PresenterTestCase
  setup do
    stubs_helper_method(:params).returns(action: "index", controller: "api/detailed_guides")
    @first_result = "a"
    @second_result = "b"
    @page = Kaminari.paginate_array([@first_result, @second_result]).page(1).per(10)
    @page.stubs(last_page?: false, first_page?: false, current_page: 2)
    @presenter = Api::PagePresenter.new(@page, @view_context)
  end

  test "json includes each result in page" do
    @first_result.stubs(:as_json).returns({first: :result})
    @second_result.stubs(:as_json).returns({second: :result})
    assert_equal [{first: :result}, {second: :result}], @presenter.as_json[:results]
  end

  test "json includes next page url if next page available" do
    @page.stubs(:last_page?).returns(false)
    assert_equal api_detailed_guides_url(page: 3), @presenter.as_json[:next_page_url]
  end

  test "json excludes next page url if no next page" do
    @page.stubs(:last_page?).returns(true)
    assert_nil @presenter.as_json[:next_page_url]
  end

  test "json includes previous page url if next page available" do
    @page.stubs(:first_page?).returns(false)
    assert_equal api_detailed_guides_url(page: 1), @presenter.as_json[:previous_page_url]
  end

  test "json excludes previous page url if no next page" do
    @page.stubs(:first_page?).returns(true)
    assert_nil @presenter.as_json[:previous_page_url]
  end

  test 'json includes total_count from collection as total' do
    assert_equal @page.total_count, @presenter.as_json[:total]
  end

  test 'json includes num_pages from collection as pages' do
    assert_equal @page.num_pages, @presenter.as_json[:pages]
  end

  test 'json includes limit_value form collection as page_size' do
    assert_equal @page.limit_value, @presenter.as_json[:page_size]
  end

  test 'json includes current_page from collection as current_page' do
    assert_equal @page.current_page, @presenter.as_json[:current_page]
  end

  test 'json includes start_index by calculating offset from the collection\'s current_page and limit_value' do
    @page.stubs(:current_page).returns 4
    @page.stubs(:limit_value).returns 7
    assert_equal 22, @presenter.as_json[:start_index]
  end

  test 'links include a rel=self url pointing to the current page' do
    self_link = @presenter.links.detect {|(url, attrs)| attrs['rel'] == 'self' }
    assert self_link
    self_url, _ = *self_link
    assert_equal api_detailed_guides_url(page: 2), self_url
  end

  test 'links include a rel=next url pointing to the next page if it has a next page' do
    @page.stubs(:last_page?).returns false
    next_link = @presenter.links.detect {|(url, attrs)| attrs['rel'] == 'next'}
    assert next_link
    next_url, _ = *next_link
    assert_equal api_detailed_guides_url(page: 3), next_url
  end

  test 'links do not include a rel=next url if it is the last page' do
    @page.stubs(:last_page?).returns true
    next_link = @presenter.links.detect {|(url, attrs)| attrs['rel'] == 'next'}
    refute next_link
  end

  test 'links include a rel=previous url pointing to the previous page if it has a previous page' do
    @page.stubs(:first_page?).returns false
    previous_link = @presenter.links.detect {|(url, attrs)| attrs['rel'] == 'previous'}
    assert previous_link
    previous_url, _ = *previous_link
    assert_equal api_detailed_guides_url(page: 1), previous_url
  end

  test 'links do not include a rel=previous url if it is the first page' do
    @page.stubs(:first_page?).returns true
    previous_link = @presenter.links.detect {|(url, attrs)| attrs['rel'] == 'previous'}
    refute previous_link
  end

end
