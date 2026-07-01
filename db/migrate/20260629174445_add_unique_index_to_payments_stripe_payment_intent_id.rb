class AddUniqueIndexToPaymentsStripePaymentIntentId < ActiveRecord::Migration[8.1]
  def change
    add_index :payments, :stripe_payment_intent_id, unique: true
  end
end
