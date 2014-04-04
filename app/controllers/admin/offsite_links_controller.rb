class Admin::OffsiteLinksController < Admin::BaseController
  before_filter :find_parent
  before_filter :load_offsite_link, except: [:new, :create]

  def new
    @offsite_link = OffsiteLink.new
  end

  def create
    @parent.offsite_links.new(offsite_link_params)
    if @parent.save
      flash[:notice] = "An offsite link has been created focr #{@parent.name}"
      if @parent.is_a? Classification
        redirect_to polymorphic_path([:admin, @parent, :classification_featurings])
      else
        redirect_to polymorphic_path([:features, :admin, @parent])
      end
    else
      @offsite_link = OffsiteLink.new(offsite_link_params)
      render :new
    end
  end

  def edit
  end

  def update
    if @offsite_link.update_attributes(offsite_link_params)
      redirect_to offsite_link_path(@offsite_link)
    else
      render :edit
    end
  end

  def show
    redirect_to offsite_link_path(@offsite_link)
  end

private

  def find_parent
    @parent = WorldLocation.find(params[:world_location_id]) if params[:world_location_id]
    @parent = Organisation.find(params[:organisation_id]) if params[:organisation_id]
    @parent = Topic.find(params[:topic_id]) if params[:topic_id]
    @parent = TopicalEvent.find(params[:topical_event_id]) if params[:topical_event_id]
  end

  def offsite_link_path(offsite_link)
    polymorphic_url([:features, :admin, offsite_link.parent])
  end

  def offsite_link_params
    params.require(:offsite_link)
    .permit(:title, :summary, :link_type, :url)
  end

  def load_offsite_link
    @offsite_link = OffsiteLink.find(params[:id])
  end

end
