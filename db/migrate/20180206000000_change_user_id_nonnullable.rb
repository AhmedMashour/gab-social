# class ChangeUserIdNonnullable < ActiveRecord::Migration[5.1]
#   def change
#     change_column_null :invites, :user_id, false
#     change_column_null :web_settings, :user_id, false
#   end
# end
class ChangeUserIdNonnullable < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "invites" ADD CONSTRAINT "invites_user_id_null" CHECK ("user_id" IS NOT NULL) NOT VALID'
    end
    safety_assured do
      execute 'ALTER TABLE "web_settings" ADD CONSTRAINT "web_settings_user_id_null" CHECK ("user_id" IS NOT NULL) NOT VALID'
    end
  end
end

class ValidateChangeUserIdNonnullable < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "invites" VALIDATE CONSTRAINT "invites_user_id_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "web_settings" VALIDATE CONSTRAINT "web_settings_user_id_null"'
    end
    
    change_column_null :invites, :user_id, false
    change_column_null :web_settings, :user_id, false

    safety_assured do
      execute 'ALTER TABLE "invites" DROP CONSTRAINT "invites_user_id_null"'
    end
    safety_assured do
      execute 'ALTER TABLE "web_settings" DROP CONSTRAINT "web_settings_user_id_null"'
    end
  end
end
