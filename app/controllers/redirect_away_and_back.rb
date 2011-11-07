module RedirectAwayAndBack
  extend ActiveSupport::Concern

  included do
    before_filter :store_return_uri_in_session
    helper_method :return_uri
  end

  protected

  def store_return_uri_in_session
    if params[:return_uri]
      store_return_uri params[:return_uri]
    elsif params.keys.include? "clear_return_uri"
      store_return_uri nil
    end
  end

  def return_uri
    session[:return_uri]
  end

  def store_return_uri(uri)
    session[:return_uri] = uri
  end

  def redirect_away(*args)
    if request.get?
      store_return_uri(request.fullpath)
    else
      store_return_uri(nil) unless params[:return_uri]
    end
    redirect_to *args
  end

  def redirect_back(*args)
    if return_uri
      redirect_to return_uri
      store_return_uri nil
    elsif !args.empty?
      redirect_to *args
    else
      redirect_to root_url
    end
  end
end