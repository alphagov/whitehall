class Admin::FeaturedTopicsAndPoliciesListsController < Admin::BaseController
  before_filter :load_organisation
  before_filter :fetch_featured_topics_and_policies_list

  def show
    fetch_topics_and_policies
    @featured_items = @featured_topics_and_policies_list.featured_items.current.order(:ordering).to_a
    @featured_items << @featured_topics_and_policies_list.featured_items.build(item_type: 'Topic')
  end

  def update
    params_with_item_ids = prepare_feature_item_params(params[:featured_topics_and_policies_list])
    if @featured_topics_and_policies_list.update_attributes(params_with_item_ids)
      redirect_to admin_organisation_featured_topics_and_policies_list_path(@organisation), notice: "Featured topics and policies for #{@organisation.name} updated"
    else
      fetch_topics_and_policies
      # this is to make sure we only expose current items but also doesn't
      # reload from the db and clobber the user's unsaved changes
      ids = FeaturedItem.where(featured_topics_and_policies_list_id: @featured_topics_and_policies_list.id).current.map(&:id)
      @featured_items = @featured_topics_and_policies_list.featured_items.
                          select { |fi| ids.include?(fi.id) || fi.id.nil? }.
                          sort_by { |fi| }.sort_by { |fi| fi.ordering || 99 }
      render :show
    end
  end

  private
  def fetch_topics_and_policies
    @topics = Topic.all
    @policies = Policy.latest_edition.with_translations.includes(:document)
  end

  def load_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def fetch_featured_topics_and_policies_list
    @featured_topics_and_policies_list = @organisation.featured_topics_and_policies_list || @organisation.build_featured_topics_and_policies_list
  end

  def prepare_feature_item_params(feature_list_params)
    (feature_list_params['featured_items_attributes'] || {}).each do |k, v|
      prepare_item_id_param(v)
      prepare_ended_at_param(v)
      # this helps when new lists are created at the same time as new items
      v['featured_topics_and_policies_list'] = @featured_topics_and_policies_list
    end
    feature_list_params
  end

  def prepare_item_id_param(feature_item_params)
    case feature_item_params['item_type']
    when 'Topic'
      feature_item_params.delete('document_id')
      feature_item_params['item_id'] = feature_item_params.delete('topic_id')
    when 'Document'
      feature_item_params.delete('topic_id')
      feature_item_params['item_id'] = feature_item_params.delete('document_id')
    else
      feature_item_params.delete('topic_id')
      feature_item_params.delete('document_id')
    end
  end

  def prepare_ended_at_param(feature_item_params)
    unfeature = feature_item_params.delete('unfeature')
    if unfeature && unfeature == '1'
      feature_item_params['ended_at'] = Time.current
    end
  end
end
