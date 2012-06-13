require 'test_helper'

class RolePresenterTest < PresenterTestCase
  setup do
    @role = stub_record(:role)
    @presenter = RolePresenter.decorate(@role)
  end

  test 'url is the ministerial_role_url if role is ministerial' do
    @role.stubs(:ministerial?).returns(true)
    assert_equal ministerial_role_url(@role), @presenter.url
  end

  test 'url is nil if appointed role is not ministerial' do
    @role.stubs(:ministerial?).returns(false)
    assert_nil @presenter.url
  end

  test 'link links name to url if url available' do
    @presenter.stubs(:url).returns('http://example.com/ministers/minister-of-funk')
    @role.stubs(:name).returns('The Minister of Funk')
    assert_select_from @presenter.link, 'a[href="http://example.com/ministers/minister-of-funk"]', text: 'The Minister of Funk'
  end

  test 'link returns just name if url unavailable' do
    @presenter.stubs(:url).returns(nil)
    @role.stubs(:name).returns('The Minister of Funk')
    assert_equal 'The Minister of Funk', @presenter.link
  end
end