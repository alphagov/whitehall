require "test_helper"

class Admin::CountriesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should allow modification of existing country data' do
    country = create(:country)

    get :edit, id: country

    assert_template 'countries/edit'
    assert_select "textarea[name='country[about]'].previewable.govspeak"
    assert_select '#govspeak_help'
  end

  test 'updating should modify the country' do
    country = create(:country)

    put :update, id: country, country: { about: 'country-about' }

    country.reload
    assert_equal 'country-about', country.about
  end
end