class ChangeBlogsDescriptionToText < ActiveRecord::Migration
  def up
    change_column :blogs, :description, :text
  end

  def down
    change_column :blogs, :description, :string
  end
end
