module AdminEditionControllerScheduledPublishingTestHelpers
  extend ActiveSupport::Concern

  def scheduled_publication_attributes(scheduled_publication)
    attributes = {}
    %w{year month day hour min}.each.with_index do |method, i|
      attributes["scheduled_publication(#{i+1}i)"] = scheduled_publication ? scheduled_publication.send(method.to_sym) : ""
    end
    attributes
  end

  module ClassMethods
    def should_allow_scheduled_publication_of(edition_type)
      document_type_class = edition_type.to_s.classify.constantize

      view_test "new displays scheduled_publication date and time fields" do
        get :new

        assert_select "form#new_edition" do
          assert_select "input[type=checkbox][name='scheduled_publication_active']"
          assert_select "select[name*='edition[scheduled_publication']", count: 5
        end
      end

      view_test "GET :show with a draft scheduled edition displays the 'Force schedule', but not the 'Force publish' button" do
        login_as :gds_editor
        edition = create(edition_type, :draft, scheduled_publication: 1.day.from_now)
        get :show, id: edition

        assert_select force_schedule_button_selector(edition), count: 1
        refute_select force_publish_button_selector(edition)
        assert_select '.scheduled-publication', "Scheduled publication proposed for #{I18n.localize edition.scheduled_publication, format: :long}."
      end

      view_test "should display the 'Schedule' button for a submitted scheduled edition when viewing as an editor" do
        login_as :gds_editor
        edition = create(edition_type, :submitted, scheduled_publication: 1.day.from_now)
        get :show, id: edition

        assert_select schedule_button_selector(edition), count: 1
        assert_select '.scheduled-publication', /Scheduled publication proposed for/
      end

      view_test "should not display the 'Schedule' button if not schedulable" do
        edition = create(edition_type, :published)
        document_type_class.stubs(:find).with(edition.to_param).returns(edition)
        get :show, id: edition
        refute_select schedule_button_selector(edition)
        refute_select force_schedule_button_selector(edition)
      end

      view_test "should display the 'Unschedule' button for a scheduled publication" do
        edition = create(edition_type, :scheduled)
        get :show, id: edition
        assert_select unschedule_button_selector(edition)
      end

      view_test "should indicate publishing schedule if scheduled" do
        edition = create(edition_type, :scheduled)
        get :show, id: edition
        assert_select '.scheduled-publication', "Scheduled for publication on #{I18n.localize edition.scheduled_publication, format: :long}."
      end

      view_test "should not indicate publishing schedule if published" do
        edition = create(edition_type, :published, scheduled_publication: 1.day.ago)
        get :show, id: edition
        assert_select '.scheduled-publication', count: 0
      end

      test "create should not set scheduled_publication if scheduled_publication_active is not checked" do
        edition_attributes = controller_attributes_for(edition_type,
          first_published_at: Date.parse("2010-10-21"),
          publication_type_id: PublicationType::ResearchAndAnalysis.id
        ).merge(scheduled_publication_attributes(Time.zone.now))

        post :create, {scheduled_publication_active: "0", edition: edition_attributes}

        created_edition = document_type_class.last
        assert_equal nil, created_edition.scheduled_publication
      end

      test "create should set scheduled_publication if scheduled_publication_active is checked" do
        selected_time = Time.zone.parse("2012-01-01 09:30")
        edition_attributes = controller_attributes_for(edition_type,
          first_published_at: Date.parse("2010-10-21"),
          publication_type_id: PublicationType::ResearchAndAnalysis.id
        ).merge(scheduled_publication_attributes(selected_time))

        post :create, {scheduled_publication_active: "1", edition: edition_attributes}

        created_edition = document_type_class.last
        assert_equal selected_time, created_edition.scheduled_publication
      end

      view_test "edit displays scheduled_publication date and time fields" do
        edition = create(edition_type, scheduled_publication: Time.zone.parse('2060-06-03 10:30'))

        get :edit, id: edition

        assert_select "form#edit_edition" do
          assert_select "input[type=checkbox][name='scheduled_publication_active'][checked='checked']"
          assert_select "select[name='edition[scheduled_publication(1i)]'] option[value='2060'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(2i)]'] option[value='6'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(3i)]'] option[value='3'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(4i)]'] option[value='10'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(5i)]'] option[value='30'][selected='selected']"
        end
      end

      view_test "edit displays scheduled_publication date and time fields when scheduled_publication is nil, defaulting to 09:30 today" do
        edition = create(edition_type, scheduled_publication: nil)

        Timecop.freeze(Time.zone.parse('2012-03-01 11:00')) do
          get :edit, id: edition
        end

        assert_select "form#edit_edition" do
          assert_select "input[type=checkbox][name='scheduled_publication_active']"
          assert_select "input[type=checkbox][name='scheduled_publication_active'][checked='checked']", count: 0
          assert_select "select[name='edition[scheduled_publication(1i)]'] option[value='2012'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(2i)]'] option[value='3'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(3i)]'] option[value='1'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(4i)]'] option[value='09'][selected='selected']"
          assert_select "select[name='edition[scheduled_publication(5i)]'] option[value='30'][selected='selected']"
        end
      end

      test "update should clear scheduled_publication if scheduled_publication_active not checked" do
        selected_time = 1.day.from_now
        edition = create(edition_type, scheduled_publication: selected_time)

        edition_attributes = controller_attributes_for_instance(edition,
          {first_published_at: Date.parse("2010-06-18")}.merge(scheduled_publication_attributes(selected_time))
        )

        put :update, id: edition, edition: edition_attributes, scheduled_publication_active: "0"

        saved_edition = edition.reload
        assert_equal nil, saved_edition.scheduled_publication
      end

      test "update should set scheduled_publication if scheduled_publication_active checked" do
        edition = create(edition_type, scheduled_publication: nil)
        selected_time = Time.zone.parse("2012-07-03 09:30")

        edition_attributes = controller_attributes_for_instance(edition,
          {first_published_at: Date.parse("2010-06-18")}.merge(scheduled_publication_attributes(selected_time))
        )
        put :update, id: edition,
          edition: edition_attributes,
          scheduled_publication_active: "1"

        saved_edition = edition.reload
        assert_equal selected_time, saved_edition.scheduled_publication
      end
    end
  end
end
