module AdminEditionController::StatisticalDataSetsTests
  extend ActiveSupport::Concern

  included do
    def edition_class
      class_for(edition_type)
    end

    view_test "new should display statistical data sets field" do
      get :new

      assert_select "form#new_edition" do
        assert_select "label[for=edition_statistical_data_set_document_ids]", text: "Statistical data sets"

        assert_select "#edition_statistical_data_set_document_ids" do |elements|
          assert_equal 1, elements.length
        end
      end
    end

    test "create should associate statistical data sets with edition" do
      first_data_set = create(:statistical_data_set, document: create(:document))
      second_data_set = create(:statistical_data_set, document: create(:document))
      attributes = controller_attributes_for(edition_type)

      post :create,
           params: {
             edition: attributes.merge(
               statistical_data_set_document_ids: [first_data_set.document.id, second_data_set.document.id],
             ),
           }

      edition = edition_class.last
      assert_equal [first_data_set, second_data_set], edition.statistical_data_sets
    end

    view_test "edit should display edition statistical data sets field" do
      edition = create(edition_type) # rubocop:disable Rails/SaveBang

      get :edit, params: { id: edition }

      assert_select "form#edit_edition" do
        assert_select "label[for=edition_statistical_data_set_document_ids]", text: "Statistical data sets"

        assert_select "#edition_statistical_data_set_document_ids" do |elements|
          assert_equal 1, elements.length
        end
      end
    end

    test "update should associate statistical data sets with editions" do
      first_data_set = create(:statistical_data_set, document: create(:document))
      second_data_set = create(:statistical_data_set, document: create(:document))

      edition = create(edition_type, statistical_data_sets: [first_data_set])

      put :update,
          params: {
            id: edition,
            edition: {
              statistical_data_set_document_ids: [second_data_set.document.id],
            },
          }

      edition.reload
      assert_equal [second_data_set], edition.statistical_data_sets
    end
  end
end
