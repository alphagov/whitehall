module Admin::HomePageListController
  def is_home_page_list_controller_for(list_name, opts)
    before_action :extract_show_on_home_page_param, only: %i[create update]
    plural_name = list_name.to_s.downcase
    single_name = plural_name.singularize
    item_type = opts[:item_type]
    redirect_proc = opts[:redirect_to]
    params_name = (opts[:params_name] || single_name).to_sym
    home_page_list_controller_methods = Module.new do
      define_method(:reorder_for_home_page) do
        reordered_items = extract_items_from_ordering_params(params[:ordering] || {})
        home_page_list_container.__send__(:"reorder_#{plural_name}_on_home_page!", reordered_items)
        publish_container_to_publishing_api
        redirect_to redirect_proc.call(home_page_list_container, home_page_list_item), notice: %(#{plural_name.titleize} on home page reordered successfully)
      end

    protected

      define_method(:extract_show_on_home_page_param) do
        @show_on_home_page = params[params_name].delete(:show_on_home_page)
      end

      define_method(:handle_show_on_home_page_param) do
        if @show_on_home_page.present?
          case @show_on_home_page
          when "1"
            home_page_list_container.__send__(:"add_#{single_name}_to_home_page!", home_page_list_item)
          when "0"
            home_page_list_container.__send__(:"remove_#{single_name}_from_home_page!", home_page_list_item)
          end
        end
      end

      define_method(:extract_items_from_ordering_params) do |ids_and_orderings|
        ids_and_orderings.permit!.to_h.
          # convert to useful forms
          map { |item_id, ordering| [item_type.find_by(id: item_id), ordering.to_i] }.
          # sort by ordering
          sort_by { |_, ordering| ordering }.
          # discard ordering
          map { |item, _| item }.
          # reject any blank contacts
          compact
      end

      define_method(:publish_container_to_publishing_api) do
        home_page_list_container.try(:publish_to_publishing_api)
      end
    end
    include home_page_list_controller_methods
  end
end
