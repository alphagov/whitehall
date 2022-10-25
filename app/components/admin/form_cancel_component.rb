# frozen_string_literal: true

class Admin::FormCancelComponent < ViewComponent::Base

  def initialize(object:)
    @url_maker = Whitehall::UrlMaker.new(host: Plek.find("whitehall"))
    @object = object
  end

private

  def path
    if @object.new_record?
      case @object
      when CorporateInformationPage
        @url_maker.polymorphic_path([:admin, @object.owning_organisation, CorporateInformationPage])
      when Edition
        @url_maker.admin_editions_path
      else
        @url_maker.polymorphic_path([:admin, @object.class])
      end
    else
      case @object
      when CorporateInformationPage, Edition
        @url_maker.admin_edition_path(@object)
      else
        @url_maker.polymorphic_path([:admin, object])
      end
    end
  end
end
