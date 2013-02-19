class Admin::OrganisationsController < Admin::BaseController
  before_filter :build_organisation, only: [:new]
  before_filter :build_organisation_roles, only: [:new]
  before_filter :load_organisation, only: [:show, :edit, :update, :destroy, :documents]
  before_filter :build_organisation_classifications, only: [:new, :edit]
  before_filter :delete_absent_organisation_classifications, only: [:update]
  before_filter :build_mainstream_links, only: [:new, :edit]
  before_filter :destroy_blank_mainstream_links, only: [:create, :update]

  before_filter :social_media_helper, only: [:new, :create, :edit, :update]
  attr :social

  def index
    @organisations = Organisation.all
    @user_organisation = current_user.organisation
  end

  def new
    social.build_social_media_account(@organisation)
  end

  def create
    social.destroy_blank_social_media_accounts(params[:organisation])
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to admin_organisations_path
    else
      build_organisation_roles
      social.build_social_media_account(@organisation)
      render action: "new"
    end
  end

  def show
  end

  def documents
    @featured_editions = @organisation.featured_edition_organisations.collect { |e| e.edition }
    @editions = Edition.accessible_to(current_user).published.in_organisation(@organisation).in_reverse_chronological_order
    if @featured_editions.any?
      @editions = @editions.where(Edition.arel_table[:id].not_in @featured_editions.map(&:id))
    end
    @editions = @editions.page(params[:page]).per(20)
  end

  def edit
    social.build_social_media_account(@organisation)
    load_organisation_roles
  end

  def update
    social.destroy_blank_social_media_accounts(params[:organisation])
    if @organisation.update_attributes(params[:organisation])
      redirect_to admin_organisation_path(@organisation)
    else
      load_organisation_roles
      social.build_social_media_account(@organisation)
      render action: "edit"
    end
  end

  def destroy
    @organisation.destroy
    redirect_to admin_organisations_path
  end

  private

  def build_organisation
    @organisation = Organisation.new
  end

  def build_organisation_roles
    @ministerial_organisation_roles = []
    @management_organisation_roles = []
    @traffic_commissioner_organisation_roles = []
    @military_organisation_roles = []
    @special_representative_organisation_roles = []
  end

  def build_organisation_classifications
    n = @organisation.organisation_classifications.count
    @organisation.organisation_classifications.each.with_index do |ot, i|
      ot.ordering = i
    end
    (n...13).each do |i|
      @organisation.organisation_classifications.build(ordering: i)
    end
  end

  def delete_absent_organisation_classifications
    return unless params[:organisation] && params[:organisation][:organisation_classifications_attributes]
    params[:organisation][:organisation_classifications_attributes].each do |p|
      if p[:classification_id].blank?
        p["_destroy"] = true
      end
    end
  end

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end

  def build_mainstream_links
    unless @organisation.mainstream_links.any?(&:new_record?)
      @organisation.mainstream_links.build
    end
  end

  def load_organisation_roles
    @ministerial_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.ministerial).order(:ordering)
    @management_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.management).order(:ordering)
    @traffic_commissioner_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.traffic_commissioner).order(:ordering)
    @military_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.military).order(:ordering)
    @special_representative_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.special_representative).order(:ordering)
  end

  def destroy_blank_mainstream_links
    if params[:organisation][:mainstream_links_attributes]
      params[:organisation][:mainstream_links_attributes].each do |index, link|
        if link[:title].blank? && link[:url].blank?
          link[:_destroy] = "1"
        end
      end
    end
  end

  def social_media_helper
    @social = Whitehall::Controllers::SocialMedia.new
  end
end
