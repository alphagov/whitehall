class Admin::OrganisationsController < Admin::BaseController
  before_filter :build_organisation, only: [:new]
  before_filter :build_organisation_roles, only: [:new]
  before_filter :load_organisation, only: [:show, :edit, :update, :destroy]
  before_filter :build_organisation_topics, only: [:new, :edit]
  before_filter :delete_absent_organisation_topics, only: [:update]
  before_filter :build_social_media_account, only: [:new, :edit]
  before_filter :build_organisation_mainstream_links, only: [:new, :edit]
  before_filter :destroy_blank_phone_numbers, only: [:create, :update]
  before_filter :destroy_blank_social_media_accounts, only: [:create, :update]

  def index
    @organisations = Organisation.all
  end

  def new
  end

  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      redirect_to admin_organisations_path
    else
      build_organisation_roles
      build_social_media_account
      render action: "new"
    end
  end

  def show
    @editions = Edition.accessible_to(current_user).published.in_organisation(@organisation).by_first_published_at
  end

  def edit
    load_organisation_roles
  end

  def update
    if @organisation.update_attributes(params[:organisation])
      redirect_to admin_organisation_path(@organisation)
    else
      load_organisation_roles
      build_social_media_account
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
    @board_member_organisation_roles = []
    @traffic_commissioner_organisation_roles = []
    @military_organisation_roles = []
    @special_representative_organisation_roles = []
  end

  def build_organisation_topics
    n = @organisation.organisation_topics.count
    @organisation.organisation_topics.each.with_index do |ot, i|
      ot.ordering = i
    end
    (n...10).each do |i|
      @organisation.organisation_topics.build(ordering: i)
    end
  end

  def delete_absent_organisation_topics
    return unless params[:organisation] && params[:organisation][:organisation_topics_attributes]
    params[:organisation][:organisation_topics_attributes].each do |p|
      if p[:topic_id].blank?
        p["_destroy"] = true
      end
    end
  end

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end

  def build_social_media_account
    unless @organisation.social_media_accounts.any?(&:new_record?)
      @organisation.social_media_accounts.build
    end
  end

  def build_organisation_mainstream_links
    unless @organisation.organisation_mainstream_links.any?(&:new_record?)
      @organisation.organisation_mainstream_links.build
    end
  end

  def load_organisation_roles
    @ministerial_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.ministerial).order(:ordering)
    @board_member_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.board_member).order(:ordering)
    @traffic_commissioner_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.traffic_commissioner).order(:ordering)
    @military_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.military).order(:ordering)
    @special_representative_organisation_roles = @organisation.organisation_roles.joins(:role).merge(Role.special_representative).order(:ordering)
  end

  def destroy_blank_phone_numbers
    if params[:organisation][:contacts_attributes]
      params[:organisation][:contacts_attributes].each do |index, contact|
        if contact && contact[:contact_numbers_attributes]
          contact[:contact_numbers_attributes].each do |key, number|
            if number[:label].blank? && number[:number].blank?
              number[:_destroy] = "1"
            end
          end
        end
      end
    end
  end

  def destroy_blank_social_media_accounts
    if params[:organisation][:social_media_accounts_attributes]
      params[:organisation][:social_media_accounts_attributes].each do |index, account|
        if account[:social_media_service_id].blank? && account[:url].blank?
          account[:_destroy] = "1"
        end
      end
    end
  end
end
