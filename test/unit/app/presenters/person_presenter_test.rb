require "test_helper"

class PersonPresenterTest < ActionView::TestCase
  setup do
    setup_view_context
    @person = stub_translatable_record(:person)
    @presenter = PersonPresenter.new(@person, @view_context)
  end

  test "link links name to path" do
    @presenter.stubs(:path).returns("http://example.com/person/a-person")
    assert_select_within_html @presenter.link, 'a[href="http://example.com/person/a-person"]', text: @person.name
  end

  test "image returns an img tag" do
    @person.stubs(:image_url).returns("/link/to/image.jpg")
    assert_select_within_html @presenter.image, 'img[src="/link/to/image.jpg"]'
  end

  test "image is nil if person has no associated image" do
    @person.stubs(:image_url).returns(nil)
    assert_nil @presenter.image
  end

  test "biography generates html from the original govspeak" do
    @person.stubs(:biography).returns("## Hello")
    assert_select_within_html @presenter.biography, ".govspeak h2", text: "Hello"
  end

  test "biography is truncated for people without a current role" do
    @person.role_appointments.destroy_all
    @person.stubs(:biography).returns("This is the first paragraph.\r\n\r\nThis is the second paragraph")
    assert_no_match %r{This is the second paragraph.}, @presenter.biography
  end
end
