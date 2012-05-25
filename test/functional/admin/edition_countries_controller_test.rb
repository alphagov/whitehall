require 'test_helper'

class Admin::EditionCountriesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  test 'should allow featuring of the edition country' do
    edition_country = create(:edition_country, featured: false)
    login_as :departmental_editor
    post :update, id: edition_country, edition_country: {featured: true}
    assert edition_country.reload.featured?
  end

  test 'should allow unfeaturing of the edition country' do
    edition_country = create(:edition_country, featured: true)
    login_as :departmental_editor
    post :update, id: edition_country, edition_country: {featured: false}
    refute edition_country.reload.featured?
  end

  test "should redirect back to the country's admin edit page" do
    country = create(:country)
    edition_country = create(:edition_country, country: country)
    login_as :departmental_editor
    post :update, id: edition_country, edition_country: {}
    assert_redirected_to edit_admin_country_path(country)
  end
end