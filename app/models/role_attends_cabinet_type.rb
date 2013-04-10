class RoleAttendsCabinetType
  include ActiveRecordLikeInterface

  attr_accessor :id, :name, :footnote

  AttendsCabinet  = create(id: 1, name: "attends Cabinet", footnote: "**")
  MinisterialResponsibilities = create(id: 2, name: "attends Cabinet when Ministerial responsibilities are on the agenda", footnote: "***")
end