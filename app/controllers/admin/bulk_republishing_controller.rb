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

  def new_documents_by_organisation; end

  def search_documents_by_organisation
    unless Organisation.find_by(slug: params[:organisation_slug])
      flash[:alert] = "Organisation with slug '#{params[:organisation_slug]}' not found"
      return redirect_to(admin_bulk_republishing_documents_by_organisation_new_path)
    end

    redirect_to(admin_bulk_republishing_documents_by_organisation_confirm_path(params[:organisation_slug]))
  end

  def confirm_documents_by_organisation
    @organisation = Organisation.find_by(slug: params[:organisation_slug])
    render "admin/errors/not_found", status: :not_found unless @organisation

    @bulk_content_type_metadata = bulk_content_type_metadata.fetch(:all_documents_by_organisation)
    @republishing_event = RepublishingEvent.new
  end

  def republish_documents_by_organisation
    @organisation = Organisation.find_by(slug: params[:organisation_slug])
    return render "admin/errors/not_found", status: :not_found unless @organisation

    bulk_content_type_key = :all_documents_by_organisation
    @bulk_content_type_metadata = bulk_content_type_metadata.fetch(bulk_content_type_key)
    action = "#{@bulk_content_type_metadata[:name].upcase_first} '#{@organisation.name}' have been queued for republishing"
    bulk_content_type_value = RepublishingEvent.bulk_content_types.fetch(bulk_content_type_key)
    @republishing_event = build_republishing_event(action:, bulk_content_type: bulk_content_type_value, organisation_id: @organisation.id)

    if @republishing_event.save
      @bulk_content_type_metadata[:republish_method].call(@organisation)

      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm_documents_by_organisation"
    end
  end

  def new_documents_by_content_ids; end

  def search_documents_by_content_ids
    content_ids = content_ids_string_to_array(params[:content_ids])
    return if redirect_if_no_requested_content_ids(content_ids)

    matching_document_content_ids = Document.where(content_id: content_ids).pluck(:content_id)
    return if redirect_if_unfound_content_ids(matching_document_content_ids, content_ids)

    redirect_to(admin_bulk_republishing_documents_by_content_ids_confirm_path(params[:content_ids]))
  end

  def confirm_documents_by_content_ids
    @content_ids_string = params[:content_ids]
    content_ids = content_ids_string_to_array(@content_ids_string)
    return if redirect_if_no_requested_content_ids(content_ids)

    @matching_documents = Document.where(content_id: content_ids)
    return if redirect_if_unfound_content_ids(@matching_documents.pluck(:content_id), content_ids)

    @republishing_event = RepublishingEvent.new
  end

  def republish_documents_by_content_ids
    @content_ids_string = params[:content_ids]
    content_ids = content_ids_string_to_array(@content_ids_string)
    return if redirect_if_no_requested_content_ids(content_ids)

    @matching_documents = Document.where(content_id: content_ids)
    return if redirect_if_unfound_content_ids(@matching_documents.pluck(:content_id), content_ids)

    bulk_content_type_key = :all_documents_by_content_ids
    bulk_content_type_metadata_for_content_ids = bulk_content_type_metadata.fetch(bulk_content_type_key)
    action = "#{bulk_content_type_metadata_for_content_ids[:name].upcase_first} #{content_ids_array_to_string(content_ids)} have been queued for republishing"
    bulk_content_type_value = RepublishingEvent.bulk_content_types.fetch(bulk_content_type_key)
    @republishing_event = build_republishing_event(action:, bulk_content_type: bulk_content_type_value, content_ids:)

    if @republishing_event.save
      bulk_content_type_metadata_for_content_ids[:republish_method].call(@matching_documents.pluck(:id))

      flash[:notice] = action
      redirect_to(admin_republishing_index_path)
    else
      render "confirm_documents_by_content_ids"
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

  def build_republishing_event(action:, bulk_content_type:, content_type: nil, organisation_id: nil, content_ids: nil)
    RepublishingEvent.new(
      user: current_user,
      reason: params.fetch(:reason),
      action:,
      bulk_content_type:,
      bulk: true,
      content_type:,
      organisation_id:,
      content_ids:,
    )
  end

  def redirect_if_no_requested_content_ids(requested_content_ids)
    if requested_content_ids.empty?
      flash[:alert] = "No content IDs provided"
      redirect_to(admin_bulk_republishing_documents_by_content_ids_new_path)

      true
    end
  end

  def redirect_if_unfound_content_ids(matching_content_ids, requested_content_ids)
    unless matching_content_ids.count == requested_content_ids.count
      unfound_content_ids = requested_content_ids - matching_content_ids
      flash[:alert] = "Unable to find document(s) with the following content IDs: #{content_ids_array_to_string(unfound_content_ids)}"
      redirect_to(admin_bulk_republishing_documents_by_content_ids_new_path)

      true
    end
  end
end
