require 'test_helper'

class Admin::ConsultationsControllerTest < ActionController::TestCase
  include NationApplicabilityAssertions

  setup do
    @user = login_as "George"
  end

  test 'is an document controller' do
    assert @controller.is_a?(Admin::DocumentsController), "the controller should have the behaviour of an Admin::DocumentsController"
  end

  test 'new displays consultation form' do
    get :new

    assert_select "form[action='#{admin_consultations_path}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "input[name='document[attach_file]'][type='file']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
      assert_select "select[name*='document[organisation_ids]']"
      assert_select "select[name*='document[ministerial_role_ids]']"
      assert_nation_inapplicability_fields_exist
      assert_select "input[type='submit']"
    end
  end

  test 'creating creates a new consultation' do
    first_org = create(:organisation)
    second_org = create(:organisation)
    first_minister = create(:ministerial_role)
    second_minister = create(:ministerial_role)
    attributes = attributes_for(:consultation)

    post :create, document: attributes.merge(
      organisation_ids: [first_org.id, second_org.id],
      ministerial_role_ids: [first_minister.id, second_minister.id],
    ).merge(nation_inapplicabilities_attributes_for(Nation.wales => "http://www.visitwales.co.uk/", Nation.northern_ireland => nil))

    consultation = Consultation.last
    assert_equal attributes[:title], consultation.title
    assert_equal attributes[:body], consultation.body
    assert_equal attributes[:opening_on].to_date, consultation.opening_on
    assert_equal attributes[:closing_on].to_date, consultation.closing_on
    assert_equal [first_org, second_org], consultation.organisations
    assert_equal [first_minister, second_minister], consultation.ministerial_roles
    assert_equal [Nation.wales, Nation.northern_ireland], consultation.inapplicable_nations
    assert_equal "http://www.visitwales.co.uk/", consultation.nation_inapplicabilities.for_nation(Nation.wales).first.alternative_url
  end

  test 'creating takes the writer to the consultation page' do
    post :create, document: attributes_for(:consultation)

    assert_redirected_to admin_consultation_path(Consultation.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'show displays consultation opening date' do
    consultation = create(:consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: consultation
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test 'creating with invalid data should leave the writer in the consultation editor' do
    attributes = attributes_for(:consultation)
    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:consultation)
    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'creating with invalid data should not lose the checked nation inapplicabilities' do
    attributes = attributes_for(:consultation)
    post :create, document: attributes.merge(
      title: ''
    ).merge(nation_inapplicabilities_attributes_for(Nation.scotland => "http://www.scotland.com/"))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 0, checked: true, alternative_url: "http://www.scotland.com/")
  end

  test 'show displays consultation closing date' do
    consultation = create(:consultation, opening_on: Date.new(2010, 01, 01), closing_on: Date.new(2011, 01, 01))
    get :show, id: consultation
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end

  test 'show displays consultation attachment' do
    consultation = create(:consultation, attachment: create(:attachment))
    get :show, id: consultation
    assert_select '.attachment a', text: consultation.attachment.filename
  end

  test "show lists nation inapplicabilities when there are some" do
    draft_consultation = create(:draft_consultation)
    scotland_inapplicability = draft_consultation.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://scotland.com/")
    wales_inapplicability = draft_consultation.nation_inapplicabilities.create!(nation: Nation.wales)

    get :show, id: draft_consultation

    assert_select ".nation_inapplicabilities" do
      assert_select_object scotland_inapplicability, text: /Scotland/ do
        assert_select ".alternative_url a[href='http://scotland.com/']"
      end
      assert_select_object wales_inapplicability, text: /Wales/ do
        assert_select ".alternative_url a", count: 0
      end
    end
  end

  test "show explains the document applies to the whole of the UK" do
    draft_consultation = create(:draft_consultation)

    get :show, id: draft_consultation

    assert_select "p", "This document applies to the whole of the UK."
  end

  test 'show displays related policies' do
    policy = create(:policy)
    consultation = create(:consultation, documents_related_to: [policy])
    get :show, id: consultation
    assert_select_object policy
  end

  test 'edit displays consultation form' do
    consultation = create(:consultation)
    northern_ireland_inapplicability = consultation.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    get :edit, id: consultation

    assert_select "form[action='#{admin_consultation_path(consultation)}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "input[name='document[attach_file]'][type='file']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
      assert_select "select[name*='document[organisation_ids]']"
      assert_select "select[name*='document[ministerial_role_ids]']"
      assert_nation_inapplicability_fields_exist
      assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.discovernorthernireland.com/")
      assert_select "input[type='submit']"
    end
  end

  test 'updating should save modified policy attributes' do
    first_org = create(:organisation)
    second_org = create(:organisation)
    first_minister = create(:ministerial_role)
    second_minister = create(:ministerial_role)

    consultation = create(:consultation, organisations: [first_org], ministerial_roles: [first_minister])
    northern_ireland_inapplicability = consultation.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://www.discovernorthernireland.com/")

    put :update, id: consultation, document: {
      title: "new-title",
      body: "new-body",
      opening_on: 1.day.ago,
      closing_on: 50.days.from_now,
      organisation_ids: [second_org.id],
      ministerial_role_ids: [second_minister.id]
    }.merge(nation_inapplicabilities_attributes_for({Nation.scotland => "http://www.visitscotland.com/"}, northern_ireland_inapplicability))

    consultation.reload
    assert_equal "new-title", consultation.title
    assert_equal "new-body", consultation.body
    assert_equal 1.day.ago.to_date, consultation.opening_on
    assert_equal 50.days.from_now.to_date, consultation.closing_on
    assert_equal [second_org], consultation.organisations
    assert_equal [second_minister], consultation.ministerial_roles
    assert_equal [Nation.scotland], consultation.inapplicable_nations
    assert_equal "http://www.visitscotland.com/", consultation.nation_inapplicabilities.for_nation(Nation.scotland).first.alternative_url
  end

  test 'updating with invalid data should not lose the checked nation inapplicabilities' do
    attributes = attributes_for(:consultation)
    consultation = create(:consultation, attributes)
    scotland_inapplicability = consultation.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = consultation.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")

    put :update, id: consultation.id, document: attributes.merge(
      title: ''
    ).merge(nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability))

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
  end

  test 'updating a stale consultation should render edit page with conflicting consultation' do
    consultation = create(:draft_consultation, organisations: [build(:organisation)], ministerial_roles: [build(:ministerial_role)])
    scotland_inapplicability = consultation.nation_inapplicabilities.create!(nation: Nation.scotland, alternative_url: "http://www.scotland.com/")
    wales_inapplicability = consultation.nation_inapplicabilities.create!(nation: Nation.wales, alternative_url: "http://www.wales.com/")
    lock_version = consultation.lock_version
    consultation.update_attributes!(title: "new title")

    put :update, id: consultation, document: consultation.attributes.merge(
      lock_version: lock_version
    ).merge(nation_inapplicabilities_attributes_for({Nation.northern_ireland => "http://www.northernireland.com/"}, scotland_inapplicability, wales_inapplicability))

    assert_template 'edit'
    conflicting_consultation = consultation.reload
    assert_equal conflicting_consultation, assigns[:conflicting_document]
    assert_equal conflicting_consultation.lock_version, assigns[:document].lock_version
    assert_equal %{This document has been saved since you opened it}, flash[:alert]

    assert_nation_inapplicability_fields_exist
    assert_nation_inapplicability_fields_set_as(index: 2, checked: true, alternative_url: "http://www.northernireland.com/")
  end

  should_link_to_public_version_when_published :consultation
  should_not_link_to_public_version_when_not_published :consultation
end