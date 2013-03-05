class Api::Paginator < Struct.new(:collection, :params)
  class << self
    def paginate(collection, params)
      new(collection, params).page
    end
  end

  def current_page
    current_page = page_param > 0 ? page_param : 1
  end

  def page
    collection.page(current_page).per(20)
  end

  def page_param
    params[:page].to_i
  end
end
