require 'test_helper'

module Whitehall
  module DocumentFilter
    class OptionsTest < ActiveSupport::TestCase
      setup do
        @filter_options = Options.new
      end

      test "#label_for returns labels for publication type values" do
        Whitehall::PublicationFilterOption.all.each do |option|
          assert_equal option.label, @filter_options.label_for("publication_filter_option", option.slug)
        end

        assert_equal "All publication types", @filter_options.label_for("publication_filter_option", "all")
      end

      test "#label_for returns labels for announcement type values" do
        Whitehall::AnnouncementFilterOption.all.each do |option|
          assert_equal option.label, @filter_options.label_for("announcement_filter_option", option.slug)
        end

        assert_equal "All announcement types", @filter_options.label_for("announcement_filter_option", "all")
      end

      test '#label_for downcase the "all" option for organisations but not the orgs themselves' do
        organisation = create(:ministerial_department, :with_published_edition, name: "The National Archives", slug: "the-national-archives")

        assert_equal "The National Archives", @filter_options.label_for("departments", "the-national-archives")
        assert_equal "All departments", @filter_options.label_for("departments", "all")
      end

      test '#label_for downcase the "all" option for world locations but not the locations themselves' do
        location = create(:world_location, name: "United Kingdom", slug: "united-kingdom")

        assert_equal "United Kingdom", @filter_options.label_for("world_locations", "united-kingdom")
        assert_equal "All locations", @filter_options.label_for("world_locations", "all")
      end

      test '#label_for downcases topics' do
        topic = create(:topic, name: "Example Topic", slug: "example-topic")
        topical_event = create(:topical_event, :active, name: "Example Topical Event", slug: "example-topical-event")

        assert_equal "Example Topic", @filter_options.label_for("topics", "example-topic")
        assert_equal "Example Topical Event", @filter_options.label_for("topics", "example-topical-event")
        assert_equal "All topics", @filter_options.label_for("topics", "all")
      end

      test '#label_for downcases official docs' do
        assert_equal "Command or act papers", @filter_options.label_for("official_document_status", "command_and_act_papers")
        assert_equal "All documents", @filter_options.label_for("official_document_status", "all")
      end

      test "#valid_option_name? identifies valid option names" do
        valid_option_names = %i{
          publication_type
          organisations
          topics
          announcement_type
          official_documents
          locations
          local_government
        }

        valid_option_names.each do |option_name|
          assert Options.new.valid_option_name?(option_name)
        end

        refute Options.new.valid_option_name?(:not_a_real_option_name)
      end

      test "#valid_filter_key? identifies valid filter keys" do
        valid_filter_keys = %w{
          publication_filter_option
          departments
          topics
          announcement_filter_option
          official_document_status
          world_locations
          relevant_to_local_government
        }

        valid_filter_keys.each do |filter_key|
          assert Options.new.valid_filter_key?(filter_key)
        end

        refute Options.new.valid_filter_key?(:not_a_real_filter_key)
      end

      test "#valid_keys? returns true when given valid keys" do
        assert Options.new.valid_keys?(Options::OPTION_NAMES_TO_FILTER_KEYS.values)
        assert Options.new.valid_keys?(%w(topics departments))
        assert Options.new.valid_keys?(%w(publication_filter_option))
      end

      test "#valid_keys? returns false when given invalid keys" do
        refute Options.new.valid_keys?(%w(topics frank))
      end

      test "can get the list of options for publication_type" do
        options = @filter_options.for(:publication_type)
        assert_equal ["All publication types", "all"], options.all
        assert_equal [], options.ungrouped
        assert_include options.grouped.values.flatten(1), ["Statistics", "statistics"]
      end

      test "can get the list of options for announcement_type" do
        options = @filter_options.for(:announcement_type)
        assert_equal ["All announcement types", "all"], options.all
        assert_include options.ungrouped, ["News stories", "news-stories"]
        assert_equal({}, options.grouped)
      end

      test "can get the list of options for organisations" do
        example_organisation = create(:ministerial_department, :with_published_edition)

        options = @filter_options.for(:organisations)

        expected_grouped_options = {
          "Ministerial departments" => [[example_organisation.name, example_organisation.slug]],
          "Other departments & public bodies" => [],
          "Closed organisations" => []
        }
        assert_equal ['All departments', 'all'], options.all
        assert_equal expected_grouped_options, options.grouped
        assert_equal [], options.ungrouped
      end

      test "can get the list of options for topics" do
        topic = create(:topic)
        topical_event = create(:topical_event, :active)

        options = @filter_options.for(:topics)

        expected_grouped_options = {
          "Topics" => [[topic.name, topic.slug]],
          "Topical events" => [[topical_event.name, topical_event.slug]]
        }
        assert_equal ["All topics", "all"], options.all
        assert_equal expected_grouped_options, options.grouped
        assert_equal [], options.ungrouped
      end

      test "can get the list of options for official documents" do
        options = @filter_options.for(:official_documents)
        assert_equal ["All documents", "all"], options.all
        assert_include options.ungrouped, ['Command or act papers', 'command_and_act_papers']
        assert_equal({}, options.grouped)
      end

      test "can get the list of options for world locations" do
        location = create(:world_location)
        options = @filter_options.for(:locations)
        assert_equal ["All locations", "all"], options.all
        assert_include options.ungrouped, [location.name, location.slug]
        assert_equal({}, options.grouped)
      end

    end
  end
end
