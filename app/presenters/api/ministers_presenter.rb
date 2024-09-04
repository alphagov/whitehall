class Api::MinistersPresenter
  def content
    {
      base_path: "/government/ministers",
      content_id: "",
      document_type: "ministers_index",
      description: "Read biographies and responsibilities of Cabinet ministers and all ministers by department, as well as the whips who help co-ordinate parliamentary business.",
      details: {
        body: "Read biographies and responsibilities of <a href=\"#cabinet-ministers\" class=\"govuk-link\">Cabinet ministers</a> and all <a href=\"#ministers-by-department\" class=\"govuk-link\">ministers by department</a>, as well as the <a href=\"#whips\" class=\"govuk-link\">whips</a> who help co-ordinate parliamentary business.",
      },
      links: {
        ordered_cabinet_ministers:
      },
      locale: "en",
      phase: "live",
      rendering_app: Whitehall::RenderingApp::COLLECTIONS_FRONTEND,
      schema_name: "ministers_index",
      title: "Ministers",
      updated_at: Time.zone.now,
    }
  end

  def ordered_cabinet_ministers
    ministers = Person
                  .includes(role_appointments: { role: :translations })
                  .includes(:image)
                  .where(role: { cabinet_member: true, type: "MinisterialRole" })
                  .where(role_appointments: { ended_at: nil })
                  .distinct

    ministers.sort_by do |person|
      [person.role_appointments.map{ |appointment| appointment.role.seniority }.min, person.sort_key]
    end

    ministers.map do |person|
      {
        api_path: "/api/content/government/people#{person.base_path}",
        api_url: "http://www.dev.gov.uk/api/content/government/people#{person.base_path}",
        base_path: "/government/people/#{person.base_path}",
        content_id: person.content_id,
        details: {
         "image": person.image,
         "privy_counsellor": person.privy_counsellor,
        },
        document_type: "person",
        links: {
          role_appointments: person.role_appointments.map do |appointment|
            {
              content_id: appointment.content_id,
              details: {
                "current": appointment.current?,
                "ended_on": appointment.ended_at,
                "person_appointment_order": appointment.ordering,
                "started_on": appointment.started_at,
              },
              document_type: "role_appointment",
              links: {
                role: [
                  {
                    api_path: "/api/content/government/ministers#{appointment.role.base_path}",
                    api_url: "http://www.dev.gov.uk/api/content/government/ministers#{appointment.role.base_path}",
                    base_path: "/government/ministers/#{appointment.role.base_path}",
                    content_id: appointment.role.content_id,
                    details: {
                      body: [
                        {
                          content_type: "text/govspeak",
                          content: appointment.role.responsibilities || "",
                        }
                      ],
                      role_payment_type: appointment.role.role_payment_type,
                      seniority: appointment.role.seniority,
                      whip_organisation: {

                      }
                    },
                    document_type: appointment.role.class.name.underscore,
                    links: {},
                    locale: "en",
                    public_updated_at: appointment.role.updated_at,
                    schema_name: "role",
                    title: appointment.role.name,
                    web_url: "http://www.dev.gov.uk/government/ministers#{appointment.role.base_path}",
                    withdrawn: false
                  }
                ],
              },
              locale: "en",
              public_updated_at: appointment.updated_at,
              schema_name: "role_appointment",
              title: "#{person.name} - #{appointment.role.name}",
              withdrawn: false
            }
          end,
        },
        locale: "en",
        public_updated_at: person.updated_at,
        schema_name: "person",
        title: person.name,
        web_url: "http://www.dev.gov.uk/government/people#{person.base_path}",
        withdrawn: false
      }
    end
  end
end
