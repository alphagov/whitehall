module FilterRoutesHelper
  def announcements_filter_path(*objects)
    announcements_path(path_arguments(objects))
  end

  def publications_filter_path(*objects)
    publications_path(path_arguments(objects))
  end

  def policies_filter_path(*objects)
    policies_path(path_arguments(objects))
  end

  def filter_atom_feed_url
    url_for(params.except(:utf8, :_, :date, :direction, :page).merge(format: "atom", only_path: false))
  end

  def filter_json_url(args = {})
    url_for(params.except(:utf8, :_).merge(format: "json").merge(args))
  end

  def filter_email_signup_url(args = {})
    local_params = params.clone
    local_params.merge!(args)

    if local_params[:departments] && local_params[:departments].first != 'all'
      local_params[:organisation] = local_params[:departments].first
    end

    if local_params[:topics] && local_params[:topics].first != 'all'
      local_params[:topic] = local_params[:topics].first
    end

    if local_params.has_key?(:announcement_type_option) && local_params[:announcement_type_option] != 'all'
      local_params[:document_type] = "announcement_type_#{local_params[:announcement_type_option]}"
    elsif local_params.has_key?(:publication_filter_option) && local_params[:publication_filter_option] != 'all'
      local_params[:document_type] = "publication_type_#{local_params[:publication_filter_option]}"
    end

    url_for(local_params.slice(:organisation, :topic, :document_type, :policy).merge(controller: :email_signups, action: :show))
  end

  private

  def path_arguments(objects)
    objects.reduce({}) do |out, obj|
      if obj.is_a? Organisation
        out[:departments] = [obj.slug]
      elsif obj.is_a? Topic
        out[:topics] = [obj.slug]
      elsif obj.is_a? WorldLocation
        out[:world_locations] = [obj.slug]
      else
        out = out.merge(obj)
      end
      out
    end
  end
end
