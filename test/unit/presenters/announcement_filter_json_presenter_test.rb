require "test_helper"

class AnnouncementFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = Whitehall::DocumentFilter::FakeSearch.new
    @view_context.params[:action] = :index
    @view_context.params[:controller] = :announcements
  end

  test "includes the category of documents being presented" do
    presenter = JSON.parse(
      AnnouncementFilterJsonPresenter.new(
        @filter, @view_context, AnnouncementPresenter
      ).to_json,
    )

    assert_equal(
      "Announcement",
      presenter["category"],
      'It should have a category attribute of "Announcement"',
    )
  end
end
