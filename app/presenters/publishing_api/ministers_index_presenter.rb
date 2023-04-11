module PublishingApi
  class MinistersIndexPresenter
    attr_accessor :update_type

    def initialize(update_type: nil)
      self.update_type = update_type || "major"
    end

    def content_id
      "324e4708-2285-40a0-b3aa-cb13af14ec5f"
    end

    def content
      content = BaseItemPresenter.new(
        nil,
        title: "Ministers",
        update_type:,
      ).base_attributes

      content.merge!(
        base_path:,
        details:,
        document_type: "ministers_index",
        rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
        schema_name: "ministers_index",
      )

      content.merge!(PayloadBuilder::Routes.for(base_path))
    end

    def links
      return {} if reshuffle_in_progress?

      {
        ordered_cabinet_ministers: ordered_cabinet_ministers_content_ids,
        ordered_also_attends_cabinet: ordered_also_attends_cabinet_content_ids,
      }
    end

  private

    def details
      if reshuffle_in_progress?
        {
          reshuffle: { message: SitewideSetting.find_by(key: :minister_reshuffle_mode).govspeak },
        }
      else
        {
          body: "Read biographies and responsibilities of [Cabinet ministers](#cabinet-ministers) and all [ministers by department](#ministers-by-department), as well as the [whips](#whips) who help co-ordinate parliamentary business.",
        }
      end
    end

    def base_path
      "/government/ministers"
    end

    def reshuffle_in_progress?
      SitewideSetting.find_by(key: :minister_reshuffle_mode)&.on || false
    end

    def ordered_cabinet_ministers_content_ids
      ministers = MinisterialRole
        .cabinet
        .occupied
        .where(cabinet_member: true)
        .map(&:current_role_appointment)
        .map(&:person)
        .uniq

      sorted_ministers = ministers.sort_by do |person|
        [person.current_roles.map(&:seniority).min, person.sort_key]
      end

      sorted_ministers.map(&:content_id)
    end

    def ordered_also_attends_cabinet_content_ids
      ministers = MinisterialRole
      .also_attends_cabinet
      .occupied
      .map(&:current_role_appointment)
      .map(&:person)
      .uniq

      sorted_ministers = ministers.sort_by do |person|
        [person.current_roles.map(&:seniority).min, person.sort_key]
      end

      sorted_ministers.map(&:content_id)
    end
  end
end
