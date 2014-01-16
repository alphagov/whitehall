class Admin::FeaturedTopicsAndPoliciesListsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :fetch_featured_topics_and_policies_list

  def show
    fetch_topics_and_policies
    fetch_current_featured_items(@featured_topics_and_policies_list)
    @featured_items << @featured_topics_and_policies_list.featured_items.build(item_type: 'Topic')
  end

  def update
    prepare_feature_item_params(params[:featured_topics_and_policies_list])
    if @featured_topics_and_policies_list.update_attributes(featured_topics_and_policies_list_params)
      redirect_to admin_organisation_featured_topics_and_policies_list_path(@organisation),
        notice: "Featured topics and policies for #{@organisation.name} updated"
    else
      fetch_topics_and_policies
      fetch_current_featured_items(@featured_topics_and_policies_list)
      render :show
    end
  end

  private
  def fetch_topics_and_policies
    @topics = Topic.all
    @policies = Policy.published.with_translations.includes(:document)
  end

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def fetch_featured_topics_and_policies_list
    @featured_topics_and_policies_list = @organisation.featured_topics_and_policies_list ||
                                         @organisation.build_featured_topics_and_policies_list
  end

  def fetch_current_featured_items(list)
    @featured_items =
      if list.errors.any?
        # this is to make sure we only expose current items but also
        # don't just reload from the db and clobber any reordering or
        # inspect the in-memory instances to get current ones as that
        # clobbers marking an instance as ended
        ids = FeaturedItem.where(featured_topics_and_policies_list_id: list.id).current.map(&:id)
        list.featured_items.
          select { |fi| ids.include?(fi.id) || fi.id.nil? }.
          sort_by { |fi| fi.ordering || 99 }
      else
        list.featured_items.current.order(:ordering).to_a
      end
  end

  def featured_topics_and_policies_list_params
    params.require(:featured_topics_and_policies_list).permit(
      :summary, :link_to_filtered_policies,
      featured_items_attributes: [
        :id, :item_type, :ordering, :item_id, :ended_at
      ]
    )
  end

  def prepare_feature_item_params(feature_list_params)
    feature_list_params.fetch('featured_items_attributes', {}).each do |_, attrs|
      prepare_item_id_param(attrs)
      prepare_ended_at_param(attrs)
    end
  end

  def prepare_item_id_param(feature_item_params)
    topic_id = feature_item_params.delete('topic_id')
    document_id = feature_item_params.delete('document_id')

    case feature_item_params['item_type']
    when 'Topic'
      feature_item_params['item_id'] = topic_id
    when 'Document'
      feature_item_params['item_id'] = document_id
    end
  end

  def prepare_ended_at_param(feature_item_params)
    if feature_item_params.delete('unfeature') == '1'
      feature_item_params['ended_at'] = Time.current
    end
  end
end
