module Admin::DocumentSeriesHelper
  class DocumentSeriesGroupSelector
    class OrganisationPresenter
      def initialize(organisation)
        @organisation = organisation
      end

      def name
        @organisation.name
      end

      def document_series_groups
        @organisation.document_series.map do |series|
          series.groups.map { |group| GroupPresenter.new(group) }
        end.flatten
      end
    end

    class GroupPresenter
      def initialize(group)
        @group = group
      end

      def group_id
        @group.id
      end

      def series_and_group_name
        "#{@group.document_series.name} (#{@group.heading})"
      end
    end

    def organisations_for_select(user)
      orgs = Organisation.scoped.includes(:translations, document_series: :groups).to_a
      collection = orgs.reject { |org| org == user.organisation }
      if user.organisation
        users_org = orgs.detect { |org| org == user.organisation }
        collection.unshift(users_org)
      end
      collection.map { |org| OrganisationPresenter.new(org) }
    end
  end

  def document_series_select_options(edition, user, selected_ids)
    collection = DocumentSeriesGroupSelector.new.organisations_for_select(user)
    option_groups_from_collection_for_select(
      collection,
      :document_series_groups,
      :name,
      :group_id,
      :series_and_group_name,
      selected_ids
    )
  end
end
