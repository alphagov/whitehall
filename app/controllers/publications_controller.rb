class PublicationsController < DocumentsController

  def index
    load_filtered_publications(params)

    respond_to do |format|
      format.html
      format.json
    end
  end

  def show
    @related_policies = @document.published_related_policies
    @topics = @related_policies.map { |d| d.topics }.flatten.uniq
  end

private

  def all_publications
    Publication.published.includes(:document, :organisations, :attachments)
  end

  def document_class
    Publication
  end

  def page_size
    20
  end

  def load_filtered_publications(params)
    @publications = all_publications

    if params[:keywords].present?
      @keywords = params[:keywords].split(/\s+/)
      @publications = @publications.with_content_containing(*@keywords)
    end

    if params[:date].present?
      @date = Date.parse(params[:date])
    end

    if params[:direction].present?
      @direction = params[:direction]
      if @date.present?
        case @direction
        when "before"
          @publications = @publications.published_before(@date)
        when "after"
          @publications = @publications.published_after(@date)
        end
      end
    else
      @direction = "before"
    end

    if "after" == @direction
      @publications = @publications.in_chronological_order
    else
      @publications = @publications.in_reverse_chronological_order
    end

    @all_topics = Topic.with_content.order(:name)
    @selected_topics = []
    if params[:topics].present? && !params[:topics].include?("all")
      @selected_topics = Topic.where(slug: params[:topics])
      @publications = @publications.in_topic(@selected_topics)
    end

    @all_organisations = Organisation.joins(:published_publications).group(:name).ordered_by_name_ignoring_prefix
    @selected_departments = []
    if params[:departments].present? && !params[:departments].include?("all")
      @selected_departments = Organisation.where(slug: params[:departments])
      @publications = @publications.in_organisation(@selected_departments)
    end

    @count = @publications.count


    if params[:page].present?
      @publications = @publications.offset(page_size * (params[:page].to_i - 1))
      @page = params[:page].to_i
    else
      @page = 1
    end

    @publications = @publications.limit(page_size)

    total_pages = (@count / page_size).to_i
    mod_pages = @count % page_size

    if @page < total_pages || (@page == total_pages && mod_pages > 0)
      @next_page = @page + 1
    end

    if @page > 1
      @prev_page = @page - 1
    end
  end
end
