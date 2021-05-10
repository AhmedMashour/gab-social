# class ChangeColumnsInNotificationsNonnullable < ActiveRecord::Migration[5.1]
#   def change
#     change_column_null :notifications, :activity_id, false
#     change_column_null :notifications, :activity_type, false
#     change_column_null :notifications, :account_id, false
#     change_column_null :notifications, :from_account_id, false
#   end
# end

class ChangeColumnsInNotificationsNonnullable < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "notifications" ADD CONSTRAINT "notifications_activity_id_null" CHECK ("activity_id" IS NOT NULL) NOT VALID'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" ADD CONSTRAINT "notifications_activity_type_null" CHECK ("activity_type" IS NOT NULL) NOT VALID'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" ADD CONSTRAINT "notifications_account_id_null" CHECK ("account_id" IS NOT NULL) NOT VALID'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" ADD CONSTRAINT "notifications_from_account_id_null" CHECK ("from_account_id" IS NOT NULL) NOT VALID'
    end
  end
end

class ValidateChangeColumnsInNotificationsNonnullable < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "notifications" VALIDATE CONSTRAINT "notifications_activity_id_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" VALIDATE CONSTRAINT "notifications_activity_type_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" VALIDATE CONSTRAINT "notifications_account_id_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" VALIDATE CONSTRAINT "notifications_from_account_id_null"'
    end
    
    change_column_null :notifications, :activity_id, false
    change_column_null :notifications, :activity_type, false
    change_column_null :notifications, :account_id, false
    change_column_null :notifications, :from_account_id, false

    safety_assured do
      execute 'ALTER TABLE "notifications" DROP CONSTRAINT "notifications_activity_id_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" DROP CONSTRAINT "notifications_activity_type_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" DROP CONSTRAINT "notifications_account_id_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "notifications" DROP CONSTRAINT "notifications_from_account_id_null"'
    end
  end
end