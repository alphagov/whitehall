require 'test_helper'

class StatisticsFilterJsonPresenterTest < PresenterTestCase
  setup do
    @filter = Whitehall::DocumentFilter::FakeSearch.new
    @view_context.params[:action] = :index
    @view_context.params[:controller] = :statistics
  end

  test 'includes the category of documents being presented' do
    presenter = JSON.parse(
      StatisticsFilterJsonPresenter.new(
        @filter, @view_context, PublicationesquePresenter
      ).to_json
    )

    assert_equal(
      'Statistic',
      presenter['category'],
      'It should have a category attribute of "Statistic"'
    )
  end
end
