module Admin::PaginationHelper
  class << self
    LARGE_NUMBER_OF_PAGES = 6

    def pagination_hash(current_page:, total_pages:, path:)
      return if total_pages == 1

      self.current_page = current_page
      self.total_pages = total_pages
      self.path = normalise_path(path, current_page)

      previous_page = current_page - 1 if current_page >= 2
      next_page = current_page + 1 if current_page < total_pages

      previous_page_href = build_path_for(current_page - 1)
      self.previous_href = previous_page.present? ? previous_page_href : nil

      next_page_href = build_path_for(current_page + 1) if next_page.present?
      self.next_href = next_page_href.presence

      if total_pages >= LARGE_NUMBER_OF_PAGES
        large_page_number_hash
      else
        small_page_number_hash
      end
    end

  private

    attr_accessor :path, :previous_href, :next_href, :current_page, :total_pages

    def normalise_path(path, current_page)
      if url_has_page_param?(path)
        path
      elsif url_has_a_query_string?(path) && !url_has_an_anchor?(path)
        path + "&page=#{current_page}"
      elsif url_has_a_query_string?(path) && url_has_an_anchor?(path)
        path.gsub("#", "&page=#{current_page}#")
      elsif url_has_an_anchor?(path)
        path.gsub("#", "?page=#{current_page}#")
      else
        path + "?page=#{current_page}"
      end
    end

    def url_has_page_param?(path)
      path.include?("page=#{current_page}")
    end

    def url_has_a_query_string?(path)
      path.include?("?")
    end

    def url_has_an_anchor?(path)
      path.include?("#")
    end

    def build_path_for(page)
      path.gsub("page=#{current_page}", "page=#{page}")
    end

    def small_page_number_hash
      items = []

      [*1..total_pages].map do |page|
        items << {
          href: build_path_for(page),
          current: page == current_page,
        }
      end

      {
        previous_href:,
        next_href:,
        items:,
      }
    end

    def large_page_number_hash
      items = [
        first_page_hash,
        first_elipsis_hash,
        middle_pages_array,
        second_elipsis_hash,
        last_page_hash,
      ]
      .flatten
      .compact

      {
        previous_href:,
        next_href:,
        items:,
      }
    end

    def first_page_hash
      {
        href: build_path_for(1),
        label: "1",
        current: current_page == 1,
      }
    end

    def first_elipsis_hash
      return unless current_page >= 4

      { ellipses: true }
    end

    def middle_pages_array
      get_page_numbers.map do |page|
        {
          href: build_path_for(page),
          label: page.to_s,
          current: current_page == page,
        }
      end
    end

    def get_page_numbers
      first_page = 1
      second_page = 2
      penultimate_page = total_pages - 1
      last_page = total_pages

      case current_page
      when first_page
        [first_page + 1, first_page + 2, first_page + 3]
      when second_page
        [second_page, second_page + 1, second_page + 2]
      when last_page
        [last_page - 3, last_page - 2, last_page - 1]
      when penultimate_page
        [penultimate_page - 2, penultimate_page - 1, penultimate_page]
      else
        [current_page - 1, current_page, current_page + 1]
      end
    end

    def second_elipsis_hash
      return unless total_pages - current_page >= 3

      { ellipses: true }
    end

    def last_page_hash
      {
        href: build_path_for(total_pages),
        label: total_pages.to_s,
        current: current_page == total_pages,
      }
    end
  end
end
