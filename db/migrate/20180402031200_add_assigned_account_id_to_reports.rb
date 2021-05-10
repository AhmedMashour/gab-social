class AddAssignedAccountIdToReports < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :reports, :assigned_account, null: true, default: nil, index: {algorithm: :concurrently}
  end
end
