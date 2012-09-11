require "test_helper"

module API
  class ConsultationsControllerTest < ActionController::TestCase
    def url_base
      "http://test.host/government"
    end

    setup do
      @controller = ConsultationsController.new
      AttachmentUploader.enable_processing = true
    end

    teardown do
      AttachmentUploader.enable_processing = false
    end

    test "json should list all published consultations" do
      unpublished = create(:consultation)
      closed = create(:published_consultation,
        opening_on: 100.days.ago,
        closing_on: 80.days.ago
      )
      open = create(:published_consultation,
        opening_on: 20.days.ago,
        closing_on: 20.days.from_now
      )

      get :index, format: :json
      data = JSON.parse(response.body)

      assert_equal 2, data.length

      # We do indeed want to check equality here, not truthiness, so that
      # consumers in any language can easily parse the results:
      assert_equal true,  data[0]["open"]
      assert_equal false, data[1]["open"]

      assert_equal open.slug,   data[0]["slug"]
      assert_equal closed.slug, data[1]["slug"]

      assert_equal "#{url_base}/consultations/#{open.slug}.json",
        data[0]["api_url"]
      assert_equal "#{url_base}/consultations/#{closed.slug}.json",
        data[1]["api_url"]

      assert_equal "#{url_base}/consultations/#{open.slug}",
        data[0]["url"]
      assert_equal "#{url_base}/consultations/#{closed.slug}",
        data[1]["url"]
    end

    test "json should show details for a consultation" do
      consultation = create(:published_consultation,
        opening_on: 20.days.ago,
        closing_on: 20.days.from_now
      )

      get :show, id: consultation.slug, format: :json
      data = JSON.parse(response.body)

      assert_equal consultation.slug, data["slug"]
      assert_equal consultation.title, data["title"]
      assert_equal consultation.opening_on.strftime("%Y-%m-%d"), data["opening_on"]
      assert_equal consultation.closing_on.strftime("%Y-%m-%d"), data["closing_on"]
    end

    test "json should list organisations" do
      dept_a = create(:organisation, name: "BIS")
      dept_b = create(:organisation, name: "DFID")
      consultation = create(:published_consultation,
        organisations: [dept_a, dept_b]
      )

      get :show, id: consultation.slug, format: :json
      data = JSON.parse(response.body)

      assert_equal "BIS",  data["organisations"][0]["name"]
      assert_equal "DFID", data["organisations"][1]["name"]

      assert_equal "#{url_base}/organisations/bis",
        data["organisations"][0]["url"]
      assert_equal "#{url_base}/organisations/dfid",
        data["organisations"][1]["url"]
    end

    test "json should list inapplicable nations with URLs if available" do
      ni_without_url = create(:nation_inapplicability,
        nation: Nation.scotland
      )
      ni_with_url = create(:nation_inapplicability,
        nation: Nation.northern_ireland,
        alternative_url: "http://example.com/"
      )
      consultation = create(:published_consultation,
        nation_inapplicabilities: [ni_with_url, ni_without_url]
      )

      get :show, id: consultation.slug, format: :json
      data = JSON.parse(response.body)

      n = data["nation_inapplicabilities"]
      assert_equal "Scotland",            n[0]["name"]
      refute_includes n[0].keys, "alternative_url"
      assert_equal "Northern Ireland",    n[1]["name"]
      assert_equal "http://example.com/", n[1]["alternative_url"]
    end

    test "json should list attachments" do
      pdf = create(:attachment,
        file: fixture_file_upload("two-pages.pdf")
      )
      csv = create(:attachment,
        file: fixture_file_upload("sample-from-excel.csv")
      )

      consultation = create(:published_consultation)
      consultation.attachments << pdf
      consultation.attachments << csv

      get :show, id: consultation.slug, format: :json
      data = JSON.parse(response.body)

      a = data["attachments"]
      assert_equal "application/pdf", a[0]["content_type"]
      assert_equal 1446,              a[0]["file_size"]
      assert_equal 2,                 a[0]["number_of_pages"]
      assert_match %r{/two-pages\.pdf$}, a[0]["url"]

      assert_equal "text/csv",        a[1]["content_type"]
      assert_equal 121,               a[1]["file_size"]
      assert_match %r{/sample-from-excel\.csv$}, a[1]["url"]
      refute_includes a[1].keys, "number_of_pages"
    end

    test "json should list consultation response and attachments" do
      consultation = create(:published_consultation)
      consultation_response = consultation.create_response!(summary: "summary-of-response")
      attachment = consultation_response.attachments.create! title: 'attachment-title', file: fixture_file_upload('two-pages.pdf')

      get :show, id: consultation.slug, format: :json
      data = JSON.parse(response.body)

      cr = data["response"]
      assert_equal "summary-of-response", cr["summary"]

      a = cr['attachments']
      assert_equal "application/pdf", a[0]["content_type"]
      assert_equal 1446,              a[0]["file_size"]
      assert_equal 2,                 a[0]["number_of_pages"]
      assert_match %r{/two-pages\.pdf$}, a[0]["url"]
    end
  end
end
