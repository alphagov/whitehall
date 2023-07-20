require "test_helper"

class RolePresenterTest < ActionView::TestCase
  setup do
    setup_view_context
    @role = stub_translatable_record(:role_without_organisations)
    @presenter = RolePresenter.new(@role, @view_context)
  end

  test "path is nil if appointed role is not ministerial" do
    @role.stubs(:ministerial?).returns(false)
    assert_nil @presenter.path
  end

  test "link links name to path if path available" do
    @presenter.stubs(:path).returns("http://example.com/ministers/minister-of-funk")
    @role.stubs(:name).returns("The Minister of Funk")
    assert_select_within_html @presenter.link, 'a[href="http://example.com/ministers/minister-of-funk"]', text: "The Minister of Funk"
  end

  test "link returns just name if path unavailable" do
    @presenter.stubs(:path).returns(nil)
    @role.stubs(:name).returns("The Minister of Funk")
    assert_equal "The Minister of Funk", @presenter.link
  end

  test "current_person returns a PersonPresenter for the current appointee" do
    @role.stubs(:current_person).returns(stub_translatable_record(:person))
    assert_equal @presenter.current_person, PersonPresenter.new(@role.current_person, @view_context)
  end

  test "current_person returns a UnassignedPersonPresenter if there is no current appointee" do
    @role.stubs(:current_person).returns(nil)
    assert @presenter.current_person == RolePresenter::UnassignedPersonPresenter.new(nil, @view_context)
  end
end
