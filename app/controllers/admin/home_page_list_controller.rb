module Admin::HomePageListController
  include Rails.application.routes.url_helpers

  def is_home_page_list_controller_for(list_name, opts)
    before_action :extract_show_on_home_page_param, only: %i[create update]
    plural_name = list_name.to_s.downcase
    redirect_proc = opts[:redirect_to]
    home_page_list_controller_methods = Module.new do
      define_method(:reorder_for_home_page) do
        reordered_items = extract_items_from_ordering_params
        home_page_list_container.__send__(:"reorder_#{plural_name}_on_home_page!", reordered_items)
        publish_container_to_publishing_api
        redirect_to redirect_proc.call(home_page_list_container, home_page_list_item), notice: %(#{plural_name.titleize} on home page reordered successfully)
      end
    end
    include home_page_list_controller_methods
  end
end
