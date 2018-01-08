class Admin::OffsiteLinksController < Admin::BaseController
  before_action :load_parent
  before_action :load_offsite_link, except: %i[new create]

  def new
    @offsite_link = OffsiteLink.new
  end

  def create
    @offsite_link = OffsiteLink.new(offsite_link_params)
    @parent.offsite_links << @offsite_link
    if @parent.save
      flash[:notice] = "An offsite link has been created for #{@parent.name}"
      redirect_to offsite_links_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @offsite_link.update_attributes(offsite_link_params)
      redirect_to offsite_link_path(@offsite_link)
    else
      render :edit
    end
  end

  def destroy
    @offsite_link.destroy
    flash[:notice] = "#{@offsite_link.title} has been deleted"
    redirect_to offsite_links_path
  end

  def show
    redirect_to offsite_link_path(@offsite_link)
  end

private

  def load_parent
    @parent = WorldLocation.friendly.find(params[:world_location_id]) if params[:world_location_id]
    @parent = Organisation.friendly.find(params[:organisation_id]) if params[:organisation_id]
    @parent = Topic.friendly.find(params[:topic_id]) if params[:topic_id]
    @parent = TopicalEvent.friendly.find(params[:topical_event_id]) if params[:topical_event_id]
  end

  def load_offsite_link
    @offsite_link = OffsiteLink.find(params[:id])
  end

  def offsite_link_path(offsite_link)
    if offsite_link.parent.is_a? Classification
      polymorphic_path([:admin, offsite_link.parent, :classification_featurings])
    else
      polymorphic_url([:features, :admin, offsite_link.parent])
    end
  end

  def offsite_links_path
    if @parent.is_a? Classification
      polymorphic_path([:admin, @parent, :classification_featurings])
    else
      polymorphic_path([:features, :admin, @parent])
    end
  end

  def offsite_link_params
    params.require(:offsite_link)
    .permit(:title, :summary, :link_type, :url, :date)
  end
end
