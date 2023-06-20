require "test_helper"

class Admin::CallsForEvidenceControllerTest < ActionController::TestCase
  include TaxonomyHelper

  setup do
    login_as :writer
    @current_user.permissions << "Preview design system"
    CallForEvidenceResponseForm.any_instance.stubs(:call_for_evidence_participation).returns(stub(call_for_evidence: stub(auth_bypass_id: "auth bypass id")))
  end

  should_be_an_admin_controller

  should_allow_creating_of :call_for_evidence
  should_allow_editing_of :call_for_evidence

  should_allow_organisations_for :call_for_evidence
  should_prevent_modification_of_unmodifiable :call_for_evidence
  should_allow_alternative_format_provider_for :call_for_evidence
  should_allow_scheduled_publication_of :call_for_evidence
  should_allow_access_limiting_of :call_for_evidence
  should_render_govspeak_history_and_fact_checking_tabs_for :call_for_evidence

  view_test "new displays call for evidence fields" do
    get :new

    assert_select "form#new_edition" do
      assert_select "textarea[name='edition[summary]']"
      assert_select "select[name*='edition[opening_at']", count: 5
      assert_select "select[name*='edition[closing_at']", count: 5
      assert_select "input[type='text'][name='edition[call_for_evidence_participation_attributes][link_url]']"
      assert_select "input[type='text'][name='edition[call_for_evidence_participation_attributes][email]']"
      assert_select "input[type='text'][name='edition[call_for_evidence_participation_attributes][call_for_evidence_response_form_attributes][title]']"
      assert_select "input[type='file'][name='edition[call_for_evidence_participation_attributes][call_for_evidence_response_form_attributes][call_for_evidence_response_form_data_attributes][file]']"
    end
  end

  test "create should create a new call for evidence" do
    attributes = controller_attributes_for(
      :call_for_evidence,
      call_for_evidence_participation_attributes: {
        link_url: "http://participation.com",
        email: "countmein@participation.com",
        call_for_evidence_response_form_attributes: {
          title: "the title of the response form",
          call_for_evidence_response_form_data_attributes: {
            file: upload_fixture("two-pages.pdf"),
          },
        },
      },
    )

    post :create, params: { edition: attributes }

    call_for_evidence = CallForEvidence.last
    response_form = call_for_evidence.call_for_evidence_participation.call_for_evidence_response_form
    assert_equal attributes[:summary], call_for_evidence.summary
    assert_equal attributes[:opening_at], call_for_evidence.opening_at
    assert_equal attributes[:closing_at], call_for_evidence.closing_at
    assert_equal "http://participation.com", call_for_evidence.call_for_evidence_participation.link_url
    assert_equal "countmein@participation.com", call_for_evidence.call_for_evidence_participation.email
    assert_equal "the title of the response form", response_form.title
    assert response_form.call_for_evidence_response_form_data.file.present?
  end

  test "create should not persist external_url if the external checkbox is not checked" do
    attributes = controller_attributes_for(
      :call_for_evidence,
      external: "0",
      external_url: "http://participation.com",
      call_for_evidence_participation_attributes: {
        link_url: "http://participation.com",
        email: "countmein@participation.com",
        call_for_evidence_response_form_attributes: {
          title: "the title of the response form",
          call_for_evidence_response_form_data_attributes: {
            file: upload_fixture("two-pages.pdf"),
          },
        },
      },
    )

    post :create, params: { edition: attributes }

    call_for_evidence = CallForEvidence.last
    assert call_for_evidence.external_url.blank?
  end

  test "create should create a new call_for_evidence without call_for_evidence participation if participation fields are all blank" do
    attributes = controller_attributes_for(
      :call_for_evidence,
      call_for_evidence_participation_attributes: {
        link_url: nil,
        email: nil,
        call_for_evidence_response_form_attributes: {
          title: nil,
          call_for_evidence_response_form_data_attributes: {
            file: nil,
          },
        },
      },
    )

    post :create, params: { edition: attributes }

    call_for_evidence = CallForEvidence.last
    assert_nil call_for_evidence.call_for_evidence_participation
  end

  view_test "creating a call_for_evidence with invalid data but valid form file should still display the cached form file" do
    attributes = controller_attributes_for(
      :call_for_evidence,
      call_for_evidence_participation_attributes: {
        link_url: nil,
        email: nil,
        call_for_evidence_response_form_attributes: {
          title: nil,
          call_for_evidence_response_form_data_attributes: {
            file: upload_fixture("two-pages.pdf"),
          },
        },
      },
    )

    post :create, params: { edition: attributes }

    assert_select "form#new_edition" do
      assert_select "input[name='edition[call_for_evidence_participation_attributes][call_for_evidence_response_form_attributes][call_for_evidence_response_form_data_attributes][file_cache]'][value$='two-pages.pdf']"
      assert_select ".govuk-body.already-uploaded", text: "two-pages.pdf already uploaded"
    end
  end

  view_test "show renders the summary" do
    draft_call_for_evidence = create(:draft_call_for_evidence, summary: "a-simple-summary")
    stub_publishing_api_expanded_links_with_taxons(draft_call_for_evidence.content_id, [])

    get :show, params: { id: draft_call_for_evidence }
    assert_select ".page-header .govuk-body-lead", text: "a-simple-summary"
  end

  view_test "edit displays call_for_evidence fields" do
    response_form = create(:call_for_evidence_response_form)
    participation = create(:call_for_evidence_participation, call_for_evidence_response_form: response_form)
    call_for_evidence = create(:call_for_evidence, call_for_evidence_participation: participation)

    get :edit, params: { id: call_for_evidence }

    assert_select "form#edit_edition" do
      assert_select "textarea[name='edition[summary]']"
      assert_select "select[name*='edition[opening_at']", count: 5
      assert_select "select[name*='edition[closing_at']", count: 5
      assert_select "input[type='text'][name='edition[call_for_evidence_participation_attributes][link_url]']"
      assert_select "input[type='text'][name='edition[call_for_evidence_participation_attributes][email]']"
      assert_select "textarea[name='edition[call_for_evidence_participation_attributes][postal_address]']"
      assert_select "input[type='hidden'][name='edition[call_for_evidence_participation_attributes][call_for_evidence_response_form_attributes][id]'][value='#{response_form.id}']"
      assert_select "input[type='text'][name='edition[call_for_evidence_participation_attributes][call_for_evidence_response_form_attributes][title]']"
      assert_select "input[type='hidden'][name='edition[call_for_evidence_participation_attributes][call_for_evidence_response_form_attributes][call_for_evidence_response_form_data_attributes][id]'][value='#{response_form.call_for_evidence_response_form_data.id}']"
      assert_select "input[type='file'][name='edition[call_for_evidence_participation_attributes][call_for_evidence_response_form_attributes][call_for_evidence_response_form_data_attributes][file]']"
    end
  end

  test "update should save modified call_for_evidence attributes" do
    call_for_evidence = create(:call_for_evidence)

    put :update,
        params: { id: call_for_evidence,
                  edition: {
                    summary: "new-summary",
                    opening_at: 1.day.ago,
                    closing_at: 50.days.from_now,
                    call_for_evidence_participation_attributes: {
                      link_url: "http://consult.com",
                      email: "tell-us-what-you-think@gov.uk",
                    },
                  } }

    call_for_evidence.reload
    assert_equal "new-summary", call_for_evidence.summary
    assert_equal 1.day.ago, call_for_evidence.opening_at
    assert_equal 50.days.from_now, call_for_evidence.closing_at
    assert_equal "http://consult.com", call_for_evidence.call_for_evidence_participation.link_url
    assert_equal "tell-us-what-you-think@gov.uk", call_for_evidence.call_for_evidence_participation.email
  end

  test "update should save call_for_evidence without call_for_evidence participation if participation fields are all blank" do
    call_for_evidence = create(:call_for_evidence)

    put :update,
        params: { id: call_for_evidence,
                  edition: {
                    call_for_evidence_participation_attributes: {
                      link_url: nil,
                      email: nil,
                    },
                  } }

    call_for_evidence.reload
    assert_nil call_for_evidence.call_for_evidence_participation
  end

  view_test "updating should not allow removal of response form without explicit action" do
    response_form = create(:call_for_evidence_response_form)
    participation = create(:call_for_evidence_participation, call_for_evidence_response_form: response_form)
    call_for_evidence = create(:call_for_evidence, call_for_evidence_participation: participation)

    put :update,
        params: { id: call_for_evidence,
                  edition: {
                    call_for_evidence_participation_attributes: {
                      id: participation.id,
                      call_for_evidence_response_form_attributes: {
                        id: response_form.id,
                        _destroy: "1",
                      },
                    },
                  } }

    refute_select ".errors"
    call_for_evidence.reload
    assert_not_nil call_for_evidence.call_for_evidence_participation.call_for_evidence_response_form
  end

  view_test "updating should respect the attachment_action for response forms to keep it" do
    two_pages_pdf = upload_fixture("two-pages.pdf")
    greenpaper_pdf = upload_fixture("greenpaper.pdf")

    response_form = create(:call_for_evidence_response_form, file: two_pages_pdf)
    participation = create(:call_for_evidence_participation, call_for_evidence_response_form: response_form)
    call_for_evidence = create(:call_for_evidence, call_for_evidence_participation: participation)

    put :update,
        params: { id: call_for_evidence,
                  edition: {
                    call_for_evidence_participation_attributes: {
                      id: participation.id,
                      call_for_evidence_response_form_attributes: {
                        id: response_form.id,
                        attachment_action: "keep",
                        _destroy: "1",
                        call_for_evidence_response_form_data_attributes: {
                          id: response_form.call_for_evidence_response_form_data.id,
                          file: greenpaper_pdf,
                        },
                      },
                    },
                  } }

    refute_select ".errors"
    call_for_evidence.reload
    assert_not_nil call_for_evidence.call_for_evidence_participation.call_for_evidence_response_form
    assert_equal "two-pages.pdf", call_for_evidence.call_for_evidence_participation.call_for_evidence_response_form.call_for_evidence_response_form_data.carrierwave_file
  end

  view_test "updating should respect the attachment_action for response forms to remove it" do
    AssetManagerDeleteAssetWorker.stubs(:perform_async)

    response_form = create(:call_for_evidence_response_form)
    participation = create(:call_for_evidence_participation, call_for_evidence_response_form: response_form)
    call_for_evidence = create(:call_for_evidence, call_for_evidence_participation: participation)

    put :update,
        params: { id: call_for_evidence,
                  edition: {
                    call_for_evidence_participation_attributes: {
                      id: participation.id,
                      call_for_evidence_response_form_attributes: {
                        id: response_form.id,
                        attachment_action: "remove",
                      },
                    },
                  } }

    refute_select ".errors"
    call_for_evidence.reload
    assert_nil call_for_evidence.call_for_evidence_participation.call_for_evidence_response_form
    assert_raise(ActiveRecord::RecordNotFound) do
      response_form.call_for_evidence_response_form_data.reload
    end
    assert_raise(ActiveRecord::RecordNotFound) do
      response_form.reload
    end
  end

  view_test "updating should respect the attachment_action for response forms to replace it" do
    Services.asset_manager.stubs(:whitehall_asset).returns("id" => "http://asset-manager/assets/asset-id")
    Services.asset_manager.stubs(:delete_asset)

    two_pages_pdf = upload_fixture("two-pages.pdf")
    greenpaper_pdf = upload_fixture("greenpaper.pdf")

    response_form = create(:call_for_evidence_response_form, file: two_pages_pdf)
    participation = create(:call_for_evidence_participation, call_for_evidence_response_form: response_form)
    call_for_evidence = create(:call_for_evidence, call_for_evidence_participation: participation)

    put :update,
        params: { id: call_for_evidence,
                  edition: {
                    call_for_evidence_participation_attributes: {
                      id: participation.id,
                      call_for_evidence_response_form_attributes: {
                        id: response_form.id,
                        attachment_action: "replace",
                        _destroy: "1",
                        call_for_evidence_response_form_data_attributes: {
                          id: response_form.call_for_evidence_response_form_data.id,
                          file: greenpaper_pdf,
                        },
                      },
                    },
                  } }

    refute_select ".errors"
    call_for_evidence.reload
    assert_not_nil call_for_evidence.call_for_evidence_participation.call_for_evidence_response_form
    assert_equal "greenpaper.pdf", call_for_evidence.call_for_evidence_participation.call_for_evidence_response_form.call_for_evidence_response_form_data.carrierwave_file
  end

private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id,
    )
  end
end
