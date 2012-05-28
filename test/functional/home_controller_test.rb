require "test_helper"

class HomeControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'selects the 16 most recently updated documents to display' do
    editions = 20.times.map do |i|
      create(:published_edition, published_at: i.minutes.ago)
    end

    get :show

    assert_equal assigns(:documents), editions.take(16)
  end

  test 'assigns each listed document a unique letter (used for box layout)' do
    editions = 20.times.map do |i|
      create(:published_edition, published_at: i.minutes.ago)
    end

    get :show

    assert_select 'li#' + dom_id(editions[0]) + ".a"
    assert_select 'li#' + dom_id(editions[1]) + ".b"
    assert_select 'li#' + dom_id(editions[2]) + ".c"
    assert_select 'li#' + dom_id(editions[3]) + ".d"
  end
end