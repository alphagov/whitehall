class Admin::BulkRepublishingController < Admin::BaseController
  include Admin::RepublishingHelper

  before_action :enforce_permissions!

  def new_by_type
    @republishable_content_types_select_options = republishable_content_types_select_options
  end

  def new_by_type_redirect
    redirect_to(admin_bulk_republishing_by_type_confirm_path(params[:content_type]))
  end

  def confirm_by_type
    content_type = republishable_content_types.find { |type| type == params[:content_type].underscore.camelcase }
    return render "admin/errors/not_found", status: :not_found unless content_type

    @bulk_content_type_metadata = bulk_content_type_metadata.fetch(:all_by_type)
    @content_type = content_type
    @republishing_event = RepublishingEvent.new
  end

  def republish_by_type
    content_type = republishable_content_types.find { |type| type == params[:content_type].underscore.camelcase }
    return render "admin/errors/not_found", status: :not_found unless content_type

    bulk_content_type_key = :all_by_type
    @bulk_content_type_metadata = bulk_content_type_metadata.fetch(bulk_content_type_key)
    action = "#{@bulk_content_type_metadata[:name].upcase_first} '#{content_type}' have been queued for republishing"
    bulk_content_type_value = RepublishingEvent.bulk_content_types.fetch(bulk_content_type_key)
    @republishing_event = build_republishing_event(action:, bulk_content_type: bulk_content_type_value, content_type:)

    if @republishing_event.save
      @bulk_content_type_metadata[:republish_method].call(content_type)

      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm_by_type"
    end
  end

  def confirm
    bulk_content_type_key = params[:bulk_content_type].underscore.to_sym
    @bulk_content_type_metadata = bulk_content_type_metadata[bulk_content_type_key]
    return render "admin/errors/not_found", status: :not_found unless @bulk_content_type_metadata

    @republishing_event = RepublishingEvent.new
  end

  def republish
    bulk_content_type_key = params[:bulk_content_type].underscore.to_sym
    @bulk_content_type_metadata = bulk_content_type_metadata.fetch(bulk_content_type_key, nil)
    return render "admin/errors/not_found", status: :not_found unless @bulk_content_type_metadata

    action = "#{@bulk_content_type_metadata[:name].upcase_first} have been queued for republishing"
    bulk_content_type_value = RepublishingEvent.bulk_content_types.fetch(bulk_content_type_key)
    @republishing_event = build_republishing_event(action:, bulk_content_type: bulk_content_type_value)

    if @republishing_event.save
      @bulk_content_type_metadata[:republish_method].call

      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm"
    end
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, :republish_content)
  end

  def build_republishing_event(action:, bulk_content_type:, content_type: nil)
    RepublishingEvent.new(user: current_user, reason: params.fetch(:reason), action:, bulk_content_type:, bulk: true, content_type:)
  end
end
