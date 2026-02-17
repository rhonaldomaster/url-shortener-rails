class RemoveClicksFromUrls < ActiveRecord::Migration[7.2]
  def change
    remove_column :urls, :clicks, :integer
  end
end
