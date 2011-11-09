module ResourceTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_render_a_list_of(plural)
      type = plural.to_s.singularize
      test "index links to published #{plural}" do
        thing = create(:"published_#{type}", title: "#{type}-title")
        thing_path = send("#{type}_path", thing.document_identity)
        get :index
        assert_select "##{plural}" do
          assert_select_object thing do
            assert_select "a[href=#{thing_path}]"
            assert_select ".title", text: "#{type}-title"
          end
        end
      end

      test "index excludes unpublished #{plural}" do
        thing = create(:"draft_#{type}")
        get :index
        assert_select_object thing, count: 0
      end

      test "index lists newest #{plural} first" do
        oldest_thing = create(:"published_#{type}", title: 'oldest', published_at: 4.hours.ago)
        newest_thing = create(:"published_#{type}", title: 'newest', published_at: 2.hours.ago)
        get :index
        assert_equal [newest_thing, oldest_thing], assigns[plural.to_sym]
      end

      test "index doesn't display an empty list if there aren't any #{plural}" do
        get :index
        assert_select "##{plural} ul", count: 0
      end
    end
  end
end
