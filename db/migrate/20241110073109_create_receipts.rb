class CreateReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :receipts do |t|
      t.string :store
      t.datetime :date

      t.timestamps
    end
  end
end
