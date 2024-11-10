class Item < ApplicationRecord
  belongs_to :category
  belongs_to :receipt

  validates :name, presence: true
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }

  default_scope { joins(:receipt).where(receipts: { date: Date.current.beginning_of_month..Date.current.end_of_month }) }
end
