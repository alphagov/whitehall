module ResourceTestHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_render_a_list_of(plural, timestamp_key = :first_published_at)
      type = plural.to_s.singularize
      test "index links to published #{plural}" do
        thing = create(:"published_#{type}", title: "#{type}-title")
        get :index
        thing_path = send("#{type}_path", thing.document)
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
        refute_select_object thing
      end

      test "index lists newest #{plural} first" do
        oldest_thing = create(:"published_#{type}", title: 'oldest', timestamp_key => 4.hours.ago)
        newest_thing = create(:"published_#{type}", title: 'newest', timestamp_key => 2.hours.ago)
        get :index
        assert_equal [newest_thing, oldest_thing], assigns(plural.to_sym)
      end

      test "index doesn't display an empty list if there aren't any #{plural}" do
        get :index
        refute_select "##{plural} ul"
      end

      test "index avoids n+1 selects" do
        10.times { create(:"published_#{type}") }
        queries_used = count_queries { get :index }
        assert 10 > queries_used, "Expected less than 10 queries, #{queries_used} were counted"
      end
    end
  end
end
