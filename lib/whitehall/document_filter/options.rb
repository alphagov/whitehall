module Whitehall
  module DocumentFilter
    class Options

      def initialize(options = {})
        @locale = options[:locale] || I18n.locale
        @cache_time = options[:cache_time] || 30.minutes

        @options_by_key = {
          'publication_filter_option' => all_publication_options,
          'announcement_type_option' => all_announcement_options,
          'departments[]' => organisations[:grouped_options].values.unshift(organisations[:all_option]),
          'topics[]' => topics[:grouped_options].values.unshift(organisations[:all_option]),
          'world_locations[]' => all_location_options,
          'official_document_status' => all_official_documents_options
        }
      end

      def publication_type
        @publication_type ||= group_options(all_publication_options)
      end

      def announcement_type
        @announcement_type ||= group_options(all_announcement_options)
      end

      def organisations
        @organisations ||= Rails.cache.fetch("filter_options/organisations/#{@locale}", expires_in: @cache_time) do
          all_orgs = Organisation.with_published_editions.with_translations(@locale).ordered_by_name_ignoring_prefix

          closed_orgs, open_orgs = all_orgs.partition(&:closed?)
          ministerial_orgs, other_orgs = open_orgs.partition(&:ministerial_department?)

          grouped_orgs = {
            'Ministerial departments' => ministerial_orgs.map { |o| [o.name, o.slug] },
            'Other departments & public bodies' => other_orgs.map { |o| [o.name, o.slug] },
            'Closed organisations' => closed_orgs.map { |o| [o.name, o.slug] }
          }

          return {
            all_option: ["All departments", "all"],
            grouped_options: grouped_orgs,
            solo_options: []
          }
        end
      end

      def topics
        @topics ||= Rails.cache.fetch("filter_options/topics", expires_in: @cache_time) do
          grouped_topics = {
            'Topics' => Topic.alphabetical.map { |o| [o.name, o.slug] },
            'Topical events' => TopicalEvent.active.order_by_start_date.map { |o| [o.name, o.slug] }
          }

          return {
            all_option: ["All topics", "all"],
            grouped_options: grouped_topics,
            solo_options: []
          }
        end
      end

      def official_documents
        @official_documents ||= group_options(all_official_documents_options)
      end

      def locations
        @locations ||= group_options(all_location_options)
      end

    protected

      def all_publication_options
        @all_publication_options ||= Whitehall::PublicationFilterOption.all.sort_by(&:label).map do |option|
          [option.label, option.slug, option.group_key]
        end.unshift(["All publication types", "all"])
      end

      def all_announcement_options
        @all_announcement_options ||= Whitehall::AnnouncementFilterOption.all.sort_by(&:label).map do |option|
          [option.label, option.slug, option.group_key]
        end.unshift(["All announcement types", "all"])
      end

      def all_official_documents_options
        @all_official_documents_options ||= [
          ['All documents', 'all'],
          ['Command or act papers', 'command_and_act_papers'],
          ['Command papers only', 'command_papers_only'],
          ['Act papers only', 'act_papers_only']
        ]
      end

      def all_location_options
        @all_location_options ||= WorldLocation.includes(:translations).ordered_by_name.map do |location|
          [location.name, location.slug]
        end.unshift([I18n.t("document_filters.world_locations.all"), "all"])
      end

      def group_options(all_options)
        all = all_options.first
        grouped_options = all_options[1..-1].group_by(&:third)
        solo_options = grouped_options.delete(nil) || []

        {
          all_option: all,
          grouped_options: grouped_options,
          solo_options: solo_options
        }
      end

    end
  end
end
