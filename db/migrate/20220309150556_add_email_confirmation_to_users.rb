class AddEmailConfirmationToUsers < ActiveRecord::Migration[7.0]
  def change
    # use bulk to add multiple columns to a table
    change_table :users, bulk: true do |t|
      t.boolean :email_confirmed, default: false
      t.string :confirm_token
    end
  end
end
