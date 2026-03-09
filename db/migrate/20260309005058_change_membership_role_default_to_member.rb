class ChangeMembershipRoleDefaultToMember < ActiveRecord::Migration[8.1]
  def change
    change_column_default :memberships, :role, from: 0, to: 1
  end
end
