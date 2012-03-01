require 'test_helper'

class Admin::DocumentCountriesControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  test 'should allow featuring of the document country' do
    document_country = create(:document_country, featured: false)
    login_as :departmental_editor
    post :update, id: document_country, document_country: {featured: true}
    assert document_country.reload.featured?
  end

  test 'should allow unfeaturing of the document country' do
    document_country = create(:document_country, featured: true)
    login_as :departmental_editor
    post :update, id: document_country, document_country: {featured: false}
    refute document_country.reload.featured?
  end

  test "should redirect back to the country's admin edit page" do
    country = create(:country)
    document_country = create(:document_country, country: country)
    login_as :departmental_editor
    post :update, id: document_country, document_country: {}
    assert_redirected_to edit_admin_country_path(country)
  end
end