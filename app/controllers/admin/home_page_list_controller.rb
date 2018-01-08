module Admin::HomePageListController
  def is_home_page_list_controller_for(list_name, opts)
    plural_name = list_name.to_s.downcase
    single_name = plural_name.singularize
    item_type = opts[:item_type]
    redirect_proc = opts[:redirect_to]
    container_name = opts[:contained_by]
    params_name = (opts[:params_name] || single_name).to_sym
    home_page_list_controller_methods = Module.new do
      define_method(:remove_from_home_page) do
        @show_on_home_page = '0'
        handle_show_on_home_page_param
        redirect_to redirect_proc.call(home_page_list_container, home_page_list_item), notice: %{"#{home_page_list_item.title}" removed from home page successfully}
      end

      define_method(:add_to_home_page) do
        @show_on_home_page = '1'
        handle_show_on_home_page_param
        redirect_to redirect_proc.call(home_page_list_container, home_page_list_item), notice: %{"#{home_page_list_item.title}" added to home page successfully}
      end

      define_method(:reorder_for_home_page) do
        reordered_items = extract_items_from_ordering_params(params[:ordering] || {})
        home_page_list_container.__send__(:"reorder_#{plural_name}_on_home_page!", reordered_items)
        redirect_to redirect_proc.call(home_page_list_container, home_page_list_item), notice: %{#{plural_name.titleize} on home page reordered successfully}
      end

    protected

      define_method(:home_page_list_item) do
        instance_variable_get("@#{single_name}")
      end

      define_method(:home_page_list_container) do
        instance_variable_get("@#{container_name}")
      end

      define_method(:extract_show_on_home_page_param) do
        @show_on_home_page = params[params_name].delete(:show_on_home_page)
      end

      define_method(:handle_show_on_home_page_param) do
        if @show_on_home_page.present?
          if @show_on_home_page == '1'
            home_page_list_container.__send__(:"add_#{single_name}_to_home_page!", home_page_list_item)
          elsif @show_on_home_page == '0'
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
    end
    self.before_action :extract_show_on_home_page_param, only: [:create, :update]
    include home_page_list_controller_methods
  end
end
