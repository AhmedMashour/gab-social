# class AddCreatedByApplicationIdToUsers < ActiveRecord::Migration[5.2]
#   disable_ddl_transaction!

#   def change
#     add_reference :users, :created_by_application, foreign_key: { to_table: 'oauth_applications', on_delete: :nullify }, index: false
#     add_index :users, :created_by_application_id, algorithm: :concurrently
#   end
# end

class AddCreatedByApplicationIdToUsers < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :users, :created_by_application, index: {algorithm: :concurrently}
  end
end

