# class AddInviteIdToUsers < ActiveRecord::Migration[5.1]
#   def change
#     add_reference :users, :invite, null: true, default: nil, foreign_key: { on_delete: :nullify }, index: false
#   end
# end
class AddInviteIdToUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :users, :invite, null: true, default: nil, index: {algorithm: :concurrently}
  end
end
