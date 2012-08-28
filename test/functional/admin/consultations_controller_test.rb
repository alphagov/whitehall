require 'test_helper'

class Admin::ConsultationsControllerTest < ActionController::TestCase

  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :consultation
  should_allow_creating_of :consultation
  should_allow_editing_of :consultation
  should_allow_revision_of :consultation

  should_show_document_audit_trail_for :consultation, :show
  should_show_document_audit_trail_for :consultation, :edit

  should_allow_related_policies_for :consultation
  should_allow_organisations_for :consultation
  should_allow_ministerial_roles_for :consultation
  should_allow_attachments_for :consultation
  should_show_inline_attachment_help_for :consultation
  should_allow_attached_images_for :consultation
  should_allow_attachment_references_for :consultation
  should_not_use_lead_image_for :consultation
  should_be_rejectable :consultation
  should_be_publishable :consultation
  should_be_force_publishable :consultation
  should_be_able_to_delete_an_edition :consultation
  should_link_to_public_version_when_published :consultation
  should_not_link_to_public_version_when_not_published :consultation
  should_prevent_modification_of_unmodifiable :consultation
  should_allow_alternative_format_provider_for :consultation

  test 'new displays consultation fields' do
    get :new

    assert_select "form#edition_new" do
      assert_select "textarea[name='edition[summary]']"
      assert_select "select[name*='edition[opening_on']", count: 3
      assert_select "select[name*='edition[closing_on']", count: 3
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][link_url]']"
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][link_text]']"
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][email]']"
    end
  end

  test "create should create a new consultation" do
    attributes = attributes_for(:consultation,
      consultation_participation_attributes: {
        link_url: "http://participation.com",
        link_text: "Respond online",
        email: "countmein@participation.com"
      }
    )

    post :create, edition: attributes

    consultation = Consultation.last
    assert_equal attributes[:summary], consultation.summary
    assert_equal attributes[:opening_on].to_date, consultation.opening_on
    assert_equal attributes[:closing_on].to_date, consultation.closing_on
    assert_equal "http://participation.com", consultation.consultation_participation.link_url
    assert_equal "Respond online", consultation.consultation_participation.link_text
    assert_equal "countmein@participation.com", consultation.consultation_participation.email
  end

  test "create should create a new consultation without consultation participation if participation fields are all blank" do
    attributes = attributes_for(:consultation,
      consultation_participation_attributes: {
        link_url: nil,
        link_text: nil,
        email: nil
      }
    )

    post :create, edition: attributes

    consultation = Consultation.last
    assert_nil consultation.consultation_participation
  end

  test "show renders the summary" do
    draft_consultation = create(:draft_consultation, summary: "a-simple-summary")
    get :show, id: draft_consultation
    assert_select ".summary", text: "a-simple-summary"
  end

  test "show displays consultation opening date" do
    consultation = create(:consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: consultation
    assert_select '.opening_on', text: 'Opened on 10 October 2011'
  end

  test "show displays consultation closing date" do
    consultation = create(:consultation, opening_on: Date.new(2010, 01, 01), closing_on: Date.new(2011, 01, 01))
    get :show, id: consultation
    assert_select '.closing_on', text: 'Closed on 1 January 2011'
  end

  test "show displays consultation participation link" do
    consultation_participation = create(:consultation_participation,
      link_url: "http://participation.com",
      link_text: "Respond online",
      email: "respond@consultations-r-us.com"
    )
    consultation = create(:consultation, consultation_participation: consultation_participation)
    get :show, id: consultation
    assert_select '.participation' do
      assert_select 'a[href=?]', "http://participation.com", text: 'Respond online'
      assert_select 'a[href=?]', "mailto:respond@consultations-r-us.com", text: 'respond@consultations-r-us.com'
    end
  end

  test "edit displays consultation fields" do
    consultation = create(:consultation)

    get :edit, id: consultation

    assert_select "form#edition_edit" do
      assert_select "textarea[name='edition[summary]']"
      assert_select "select[name*='edition[opening_on']", count: 3
      assert_select "select[name*='edition[closing_on']", count: 3
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][link_url]']"
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][link_text]']"
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][email]']"
    end
  end

  test "update should save modified consultation attributes" do
    consultation = create(:consultation)

    put :update, id: consultation, edition: {
      summary: "new-summary",
      opening_on: 1.day.ago,
      closing_on: 50.days.from_now,
      consultation_participation_attributes: {
        link_url: "http://consult.com",
        link_text: "Tell us what you think",
        email: "tell-us-what-you-think@gov.uk"
      }
    }

    consultation.reload
    assert_equal "new-summary", consultation.summary
    assert_equal 1.day.ago.to_date, consultation.opening_on
    assert_equal 50.days.from_now.to_date, consultation.closing_on
    assert_equal "http://consult.com", consultation.consultation_participation.link_url
    assert_equal "Tell us what you think", consultation.consultation_participation.link_text
    assert_equal "tell-us-what-you-think@gov.uk", consultation.consultation_participation.email
  end

  test "update should save consultation without consultation participation if participation fields are all blank" do
    consultation_participation = create(:consultation_participation, link_url: "http://example.com", link_text: "Feedback")
    consultation = create(:consultation)

    put :update, id: consultation, edition: consultation.attributes.merge({
      consultation_participation_attributes: {
        link_url: nil,
        link_text: nil,
        email: nil
      }
    })

    consultation.reload
    assert_nil consultation.consultation_participation
  end
end
