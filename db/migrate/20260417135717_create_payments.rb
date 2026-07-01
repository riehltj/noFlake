class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :booking_link, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.integer :amount_cents
      t.string :status
      t.string :customer_email
      t.datetime :refunded_at

      t.timestamps
    end
  end
end
