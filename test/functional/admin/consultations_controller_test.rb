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
  should_require_alternative_format_provider_for :consultation
  show_should_display_attachments_for :consultation
  should_show_inline_attachment_help_for :consultation
  should_allow_attached_images_for :consultation
  should_allow_attachment_references_for :consultation
  should_be_rejectable :consultation
  should_be_publishable :consultation
  should_allow_unpublishing_for :consultation
  should_be_force_publishable :consultation
  should_be_able_to_delete_an_edition :consultation
  should_link_to_public_version_when_published :consultation
  should_link_to_preview_version_when_not_published :consultation
  should_not_link_to_public_version_when_not_published :consultation
  should_prevent_modification_of_unmodifiable :consultation
  should_allow_alternative_format_provider_for :consultation
  should_allow_scheduled_publication_of :consultation

  test 'new displays consultation fields' do
    get :new

    assert_select "form#edition_new" do
      assert_select "textarea[name='edition[summary]']"
      assert_select "select[name*='edition[opening_on']", count: 3
      assert_select "select[name*='edition[closing_on']", count: 3
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][link_url]']"
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][email]']"
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][consultation_response_form_attributes][title]']"
      assert_select "input[type='file'][name='edition[consultation_participation_attributes][consultation_response_form_attributes][file]']"
    end
  end

  test 'new displays consultation response fields' do
    get :new

    assert_select "form#edition_new" do
      assert_select "textarea[name='edition[response_attributes][summary]']"
      assert_select "input[type='text'][name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][title]']"
      assert_select "input[type='text'][name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][isbn]']"
      assert_select "input[type='text'][name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][unique_reference]']"
      assert_select "input[type='text'][name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][command_paper_number]']"
      assert_select "input[type='checkbox'][name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][accessible]']"
      assert_select "input[type='file'][name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][attachment_data_attributes][file]']"
    end
  end

  test 'new builds a response and a single attachment ready for populating' do
    get :new

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert_not_nil consultation.response.consultation_response_attachments.first.attachment
  end

  test "new should allow users to add consultation metadata to an attachment" do
    get :new

    assert_select "form#edition_new" do
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][order_url]']"
      assert_select "input[type=text][name='edition[edition_attachments_attributes][0][attachment_attributes][price]']"
    end
  end

  test "create should create a new consultation" do
    attributes = controller_attributes_for(:consultation,
      consultation_participation_attributes: {
        link_url: "http://participation.com",
        email: "countmein@participation.com",
        consultation_response_form_attributes: {
          title: "the title of the response form",
          file: fixture_file_upload('two-pages.pdf')
        }
      }
    )

    post :create, edition: attributes

    consultation = Consultation.last
    assert_equal attributes[:summary], consultation.summary
    assert_equal attributes[:opening_on].to_date, consultation.opening_on
    assert_equal attributes[:closing_on].to_date, consultation.closing_on
    assert_equal "http://participation.com", consultation.consultation_participation.link_url
    assert_equal "countmein@participation.com", consultation.consultation_participation.email
    assert_equal "the title of the response form", consultation.consultation_participation.consultation_response_form.title
    assert consultation.consultation_participation.consultation_response_form.file.present?
  end

  test "create should create a new consultation and a response with attachments" do
    attributes = controller_attributes_for(:consultation,
      response_attributes: {
        summary: 'response-summary',
        consultation_response_attachments_attributes: {
          '0' => {
            attachment_attributes: {
              title: 'attachment-title',
              attachment_data_attributes: {
                file: fixture_file_upload('greenpaper.pdf')
              }
            }
          }
        }
      }
    )

    post :create, edition: attributes

    consultation = Consultation.last
    assert_equal 'response-summary', consultation.response.summary
    assert_equal 1, consultation.response.attachments.length
    assert_equal 'attachment-title', consultation.response.attachments.first.title
    assert consultation.response.attachments.first.file.present?
  end

  test "create should show the cached response attachment that's been uploaded if the consultation creation fails" do
    post :create, edition: {
      title: '',
      response_attributes: {
        consultation_response_attachments_attributes: {
          '0' => {
            attachment_attributes: {
              title: 'attachment-title',
              attachment_data_attributes: {
                file: fixture_file_upload('greenpaper.pdf')
              }
            }
          }
        }
      }
    }

    assert_select "form#edition_new" do
      assert_select "input[name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][attachment_data_attributes][file_cache]'][value$='greenpaper.pdf']"
      assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
    end
  end

  test "create should build a response with a single attachment ready for populating if the form was posted without any response or attachment data and the consultation creation failed" do
    post :create, edition: {
      title: '',
      response_attributes: {}
    }

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test "create should build a single attachment ready for populating if the form was posted without any attachment data and the consultation creation failed" do
    post :create, edition: {
      title: '',
      response_attributes: {
        consultation_response_attachments_attributes: {
          '0' => {}
        }
      }
    }

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test "create should not build a new response attachment if the first attachment could not be saved and the consultation creation failed" do
    post :create, edition: {
      title: '',
      response_attributes: {
        consultation_response_attachments_attributes: {
          '0' => {
            attachment_attributes: {
              title: ''
            }
          }
        }
      }
    }

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test "create should create a new consultation without consultation participation if participation fields are all blank" do
    attributes = controller_attributes_for(:consultation,
      consultation_participation_attributes: {
        link_url: nil,
        email: nil,
        consultation_response_form_attributes: {
          title: nil,
          file: nil,
        }
      }
    )

    post :create, edition: attributes

    consultation = Consultation.last
    assert_nil consultation.consultation_participation
  end

  test "creating a consultation with invalid data but valid form file should still display the cached form file" do
    attributes = controller_attributes_for(:consultation,
      consultation_participation_attributes: {
        link_url: nil,
        email: nil,
        consultation_response_form_attributes: {
          title: nil,
          file: fixture_file_upload('two-pages.pdf')
        }
      }
    )

    post :create, edition: attributes

    assert_select "form#edition_new" do
      assert_select "input[name='edition[consultation_participation_attributes][consultation_response_form_attributes][file_cache]'][value$='two-pages.pdf']"
      assert_select ".already_uploaded", text: "two-pages.pdf already uploaded"
    end
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
      email: "respond@consultations-r-us.com"
    )
    consultation = create(:consultation, consultation_participation: consultation_participation)
    get :show, id: consultation
    assert_select '.participation' do
      assert_select 'a[href=?]', "http://participation.com", text: 'Respond online'
      assert_select 'a[href=?]', "mailto:respond@consultations-r-us.com", text: 'respond@consultations-r-us.com'
    end
  end

  test "show displays consultation postal address" do
    consultation_participation = create(:consultation_participation,
      postal_address: "Test street"
    )
    consultation = create(:consultation, consultation_participation: consultation_participation)
    get :show, id: consultation
    assert_select '.participation' do
      assert_select '.postal-address', text: 'Test street'
    end
  end

  test "show displays the response details and links to attachments" do
    consultation = create(:consultation)
    response = consultation.create_response!(summary: 'response-summary')
    attachment = response.attachments.create!(title: 'attachment-title', attachment_data: create(:attachment_data,  file: fixture_file_upload('greenpaper.pdf')))

    get :show, id: consultation

    assert_select '.consultation_response' do
      assert_select '.summary', text: 'response-summary'
      assert_select '.attachments .attachment .title', text: 'attachment-title'
      assert_select 'a[href=?]', attachment.file.url
    end
  end

  test "edit displays consultation fields" do
    response_form = create(:consultation_response_form)
    participation = create(:consultation_participation, consultation_response_form: response_form)
    consultation = create(:consultation, consultation_participation: participation)

    get :edit, id: consultation

    assert_select "form#edition_edit" do
      assert_select "textarea[name='edition[summary]']"
      assert_select "select[name*='edition[opening_on']", count: 3
      assert_select "select[name*='edition[closing_on']", count: 3
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][link_url]']"
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][email]']"
      assert_select "textarea[name='edition[consultation_participation_attributes][postal_address]']"
      assert_select "input[type='hidden'][name='edition[consultation_participation_attributes][consultation_response_form_attributes][id]'][value=?]", response_form.id
      assert_select "input[type='text'][name='edition[consultation_participation_attributes][consultation_response_form_attributes][title]']"
      assert_select "input[type='file'][name='edition[consultation_participation_attributes][consultation_response_form_attributes][file]']"
      assert_select "input[type='checkbox'][name='edition[consultation_participation_attributes][consultation_response_form_attributes][_destroy]']"
    end
  end

  test "edit shows any existing consultation response form" do
    response_form = create(:consultation_response_form, title: "response-form-title", file: fixture_file_upload('two-pages.pdf'))
    participation = create(:consultation_participation, consultation_response_form: response_form)
    consultation = create(:consultation, consultation_participation: participation)

    get :edit, id: consultation

    assert_select "form#edition_edit" do
      assert_select "a[href='#{response_form.file.url}']", File.basename(response_form.file.path)
    end
  end

  test 'edit builds a response and a single attachment ready for populating if there is no response saved for the attachment' do
    get :edit, id: create(:consultation)

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test 'edit does not build a new response if the consultation has a saved response' do
    consultation = create(:consultation)
    response = consultation.create_response!

    get :edit, id: consultation

    assert_equal response, assigns(:edition).response
  end

  test 'edit builds a single attachment ready for populating if the consultation has a response but no attachment' do
    get :edit, id: create(:consultation, response: build(:response))

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test 'edit builds a new attachment if the consultation has a saved response and a saved attachment' do
    consultation = create(:consultation)
    response = consultation.create_response!
    response.attachments << create(:attachment)

    get :edit, id: consultation

    consultation = assigns(:edition)
    assert_equal 2, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.last.attachment.new_record?
  end

  test "edit shows the details of the response and response attachments" do
    consultation = create(:consultation)
    consultation_response = consultation.create_response!(summary: 'response-summary')
    attachment = consultation_response.attachments.create!(title: 'attachment-title', attachment_data: create(:attachment_data, file: fixture_file_upload('greenpaper.pdf')))

    get :edit, id: consultation

    assert_select "form#edition_edit" do
      assert_select "textarea[name='edition[response_attributes][summary]']", text: 'response-summary'
      assert_select "input[type='text'][name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][title]'][value='attachment-title']"
      assert_select "input[type='checkbox'][name='edition[response_attributes][consultation_response_attachments_attributes][0][_destroy]']"
      assert_select "a[href='#{attachment.file.url}']", File.basename(attachment.file.path)
    end
  end

  test "update should save modified consultation attributes" do
    consultation = create(:consultation)

    put :update, id: consultation, edition: controller_attributes_for_instance(consultation,
      summary: "new-summary",
      opening_on: 1.day.ago,
      closing_on: 50.days.from_now,
      consultation_participation_attributes: {
        link_url: "http://consult.com",
        email: "tell-us-what-you-think@gov.uk"
      }
    )

    consultation.reload
    assert_equal "new-summary", consultation.summary
    assert_equal 1.day.ago.to_date, consultation.opening_on
    assert_equal 50.days.from_now.to_date, consultation.closing_on
    assert_equal "http://consult.com", consultation.consultation_participation.link_url
    assert_equal "tell-us-what-you-think@gov.uk", consultation.consultation_participation.email
  end

  test "update should build a response with a single attachment ready for populating if the form was posted without any response or attachment data and the consultation update failed" do
    consultation = create(:consultation)

    put :update, id: consultation, edition: controller_attributes_for_instance(consultation,
      title: '',
      response_attributes: {}
    )

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test "update should build a single attachment ready for populating if the form was posted without any attachment data and the consultation update failed" do
    consultation = create(:consultation)

    put :update, id: consultation, edition: controller_attributes_for_instance(consultation,
      title: '',
      response_attributes: {
        consultation_response_attachments_attributes: {
          '0' => {}
        }
      }
    )

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test "update should not build a new response attachment if the first attachment could not be saved and the consultation update failed" do
    consultation = create(:consultation)

    put :update, id: consultation, edition: controller_attributes_for_instance(consultation,
      title: '',
      response_attributes: {
        consultation_response_attachments_attributes: {
          '0' => {
            attachment_attributes: {
              title: ''
            }
          }
        }
      }
    )

    consultation = assigns(:edition)
    assert_equal 1, consultation.response.consultation_response_attachments.length
    assert consultation.response.consultation_response_attachments.first.attachment.new_record?
  end

  test "update should show the cached response attachment that's been uploaded if the consultation update fails" do
    consultation = create(:consultation)

    put :update, id: consultation, edition: controller_attributes_for_instance(consultation,
      title: '',
      response_attributes: {
        consultation_response_attachments_attributes: {
          '0' => {
            attachment_attributes: {
              title: 'attachment-title',
              attachment_data_attributes: {
                file: fixture_file_upload('greenpaper.pdf')
              }
            }
          }
        }
      }
    )

    assert_select "form#edition_edit" do
      assert_select "input[name='edition[response_attributes][consultation_response_attachments_attributes][0][attachment_attributes][attachment_data_attributes][file_cache]'][value$='greenpaper.pdf']"
      assert_select ".already_uploaded", text: "greenpaper.pdf already uploaded"
    end
  end

  test "update should save consultation without consultation participation if participation fields are all blank" do
    consultation = create(:consultation)

    put :update, id: consultation, edition: controller_attributes_for_instance(consultation,
      consultation_participation_attributes: {
        link_url: nil,
        email: nil
      }
    )

    consultation.reload
    assert_nil consultation.consultation_participation
  end

  test 'updating should allow removal of consultation response forms' do
    response_form = create(:consultation_response_form)
    participation = create(:consultation_participation, consultation_response_form: response_form)
    consultation = create(:consultation, consultation_participation: participation)

    attributes = controller_attributes_for_instance(consultation,
      consultation_participation_attributes: {
        id: participation.id,
        consultation_response_form_attributes: {
          id: response_form.id, _destroy: "1"
        }
      }
    )
    put :update, id: consultation, edition: attributes

    refute_select ".errors"
    participation.reload
    assert_nil participation.consultation_response_form
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
