class ChangeAccountIdNonnullableInLists < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "lists" ADD CONSTRAINT "lists_account_id_null" CHECK ("account_id" IS NOT NULL) NOT VALID'
    end
  end
end

class ValidateChangeAccountIdNonnullableInLists < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute 'ALTER TABLE "lists" VALIDATE CONSTRAINT "lists_account_id_null"'
    end
    change_column_null :lists, :account_id, false
    safety_assured do
      execute 'ALTER TABLE "lists" DROP CONSTRAINT "lists_account_id_null"'
    end
  end
end
