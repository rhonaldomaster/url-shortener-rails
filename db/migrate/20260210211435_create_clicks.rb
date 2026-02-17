class CreateClicks < ActiveRecord::Migration[7.2]
  def change
    create_table :clicks do |t|
      t.references :url, null: false, foreign_key: true
      t.string :ip_address
      t.string :referrer
      t.string :user_agent

      t.timestamps
    end
  end
end
