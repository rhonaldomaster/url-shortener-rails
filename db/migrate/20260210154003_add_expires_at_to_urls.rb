class AddExpiresAtToUrls < ActiveRecord::Migration[7.2]
  def change
    add_column :urls, :expires_at, :datetime
  end
end
