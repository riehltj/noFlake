class CreateBookingLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_links do |t|
      t.references :user, null: false, foreign_key: true
      t.string :slug
      t.string :service_name
      t.integer :price_cents
      t.integer :deposit_cents

      t.timestamps
    end
    add_index :booking_links, :slug, unique: true
  end
end
