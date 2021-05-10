# class ChangeAccountsNonnullableInAccountModerationNotes < ActiveRecord::Migration[5.1]
#   def change
#     change_column_null :account_moderation_notes, :account_id, false
#     change_column_null :account_moderation_notes, :target_account_id, false
#   end
# end
class ChangeAccountsNonnullableInAccountModerationNotes < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "account_moderation_notes" ADD CONSTRAINT "account_moderation_notes_account_id_null" CHECK ("account_id" IS NOT NULL) NOT VALID'
    end
  end
end

class ValidateChangeAccountsNonnullableInAccountModerationNotes < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "account_moderation_notes" VALIDATE CONSTRAINT "account_moderation_notes_account_id_null"'
    end
    change_column_null :account_moderation_notes, :account_id, false
    safety_assured do
      execute 'ALTER TABLE "account_moderation_notes" DROP CONSTRAINT "account_moderation_notes_account_id_null"'
    end
  end
end
