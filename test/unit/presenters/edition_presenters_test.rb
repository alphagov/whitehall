require 'test_helper'

class EditionPresentersTest < ActionView::TestCase

  test "page_title prepends 'Archived:' to archived editions" do
    edition   = create(:published_policy, title: 'Title of policy')
    presenter = PolicyPresenter.new(edition)

    assert_equal 'Title of policy', presenter.page_title

    edition.archive!
    assert_equal 'Archived: Title of policy', presenter.page_title
  end
end
