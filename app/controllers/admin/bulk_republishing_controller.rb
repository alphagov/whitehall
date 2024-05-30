class Admin::BulkRepublishingController < Admin::BaseController
  include Admin::RepublishingHelper

  before_action :enforce_permissions!

  def confirm_all
    bulk_content_type_key = params[:bulk_content_type].underscore.to_sym
    @bulk_content_type_metadata = bulk_content_type_metadata[bulk_content_type_key]
    return render "admin/errors/not_found", status: :not_found unless @bulk_content_type_metadata

    @republishing_event = RepublishingEvent.new
  end

  def republish_all
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
      render "confirm_all"
    end
  end

private

  def enforce_permissions!
    enforce_permission!(:administer, :republish_content)
  end

  def build_republishing_event(action:, bulk_content_type:)
    RepublishingEvent.new(user: current_user, reason: params.fetch(:reason), action:, bulk_content_type:, bulk: true)
  end
end
