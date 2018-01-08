require 'test_helper'

class Admin::TakePartPagesControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  test 'GET :index fetches all the take part pages in order' do
    page_3 = create(:take_part_page, ordering: 3)
    page_1 = create(:take_part_page, ordering: 1)
    page_2 = create(:take_part_page, ordering: 2)

    get :index

    assert_equal [page_1, page_2, page_3], assigns(:take_part_pages)
    assert_response :success
    assert_template 'index'
  end

  test 'GET :new prepares an unsaved instance' do
    get :new

    assert assigns(:take_part_page).is_a? TakePartPage
    refute assigns(:take_part_page).persisted?
    assert_response :success
    assert_template 'new'
  end

  test 'POST :create saves a new instance with the supplied valid params' do
    take_part_page_attrs = attributes_for(:take_part_page, title: 'Wear a monocle!')
                             .merge(
                               image: fixture_file_upload(
                                 'minister-of-funk.960x640.jpg',
                                 'image/jpg',
                               )
                             )

    post :create, params: { take_part_page: take_part_page_attrs }

    puts assigns(:take_part_page).errors.full_messages
    assert assigns(:take_part_page).persisted?
    assert_equal 'Wear a monocle!', assigns(:take_part_page).title
    assert_redirected_to admin_take_part_pages_path
  end

  test 'POST :create doesn\'t save the new instance when the supplied params are invalid' do
    attrs = attributes_for(:take_part_page, title: '')
    post :create, params: { take_part_page: attrs }

    refute assigns(:take_part_page).persisted?
    assert_response :success
    assert_template 'new'
  end

  test 'GET :edit fetches the supplied instance' do
    page = create(:take_part_page)

    get :edit, params: { id: page }

    assert_equal page, assigns(:take_part_page)
    assert_response :success
    assert_template 'edit'
  end

  test 'PUT :update changes the supplied instance with the supplied params' do
    attrs = attributes_for(:take_part_page, title: 'Wear a monocle!')
    page = create(:take_part_page, title: 'Drink in a gin palace!')
    post :update, params: { id: page, take_part_page: attrs }

    assert_equal page, assigns(:take_part_page)
    assert_equal 'Wear a monocle!', page.reload.title
    assert_redirected_to admin_take_part_pages_path
  end

  test 'PUT :update doesn\'t save the new instance when the supplied params are invalid' do
    attrs = attributes_for(:take_part_page, title: '')
    page = create(:take_part_page, title: 'Drink in a gin palace!')
    post :update, params: { id: page, take_part_page: attrs }

    assert_equal page, assigns(:take_part_page)
    refute_equal '', page.reload.title
    assert_equal '', assigns(:take_part_page).title
    assert_response :success
    assert_template 'edit'
  end

  test 'DELETE :destroy removes the suppliued instance' do
    page = create(:take_part_page)

    delete :destroy, params: { id: page }

    refute TakePartPage.exists?(page.id)
    assert_redirected_to admin_take_part_pages_path
  end

  test 'POST :reorder asks TakePartPage to reorder using the supplied ordering params' do
    TakePartPage.expects(:reorder!).with(%w[1 5 20 9])

    post :reorder, params: { ordering: { '1' => '1', '20' => '4', '9' => '12', '5' => '3' } }

    assert_redirected_to admin_take_part_pages_path
  end
end
