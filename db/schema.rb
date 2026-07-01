# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_30_174120) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "booking_links", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "deposit_cents"
    t.integer "price_cents"
    t.string "service_name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["slug"], name: "index_booking_links_on_slug", unique: true
    t.index ["user_id"], name: "index_booking_links_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.integer "amount_cents"
    t.bigint "booking_link_id", null: false
    t.datetime "created_at", null: false
    t.string "customer_email"
    t.datetime "refunded_at"
    t.string "status"
    t.string "stripe_payment_intent_id"
    t.datetime "updated_at", null: false
    t.index ["booking_link_id"], name: "index_payments_on_booking_link_id"
    t.index ["stripe_payment_intent_id"], name: "index_payments_on_stripe_payment_intent_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "slug", null: false
    t.string "stripe_account_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
  end

  add_foreign_key "booking_links", "users"
  add_foreign_key "payments", "booking_links"
end
