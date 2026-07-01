class AddSlugToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :slug, :string

    User.reset_column_information
    User.find_each do |user|
      base = user.email.split("@").first.parameterize
      base = "user" if base.blank?
      slug = base
      n = 1
      while User.where(slug: slug).where.not(id: user.id).exists?
        n += 1
        slug = "#{base}-#{n}"
      end
      user.update_column(:slug, slug)
    end

    change_column_null :users, :slug, false
    add_index :users, :slug, unique: true
  end

  def down
    remove_index :users, :slug
    remove_column :users, :slug
  end
end
