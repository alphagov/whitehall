class ReshuffleFollowingLiamFoxResignation < ActiveRecord::Migration
  class PeopleTable < ActiveRecord::Base
    set_table_name :people
  end

  def change
    execute %{
      UPDATE ministerial_roles
      SET person_id = (SELECT id from people where people.name = 'Philip Hammond MP')
      WHERE ministerial_roles.name = 'Secretary of State for Defence'
    }

    execute %{
      UPDATE ministerial_roles
      SET person_id = (SELECT id from people where people.name = 'Justine Greening MP')
      WHERE ministerial_roles.name = 'Secretary of State for Transport'
    }

    PeopleTable.create!(name: 'Chloe Smith')

    execute %{
      UPDATE ministerial_roles
      SET person_id = (SELECT id from people where people.name = 'Chloe Smith')
      WHERE ministerial_roles.name = 'Economic Secretary to the Treasury'
    }

    execute %{
      DELETE from people where name = 'Dr Liam Fox MP'
    }
  end
end
