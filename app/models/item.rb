class Item < ApplicationRecord
  belongs_to :category
  belongs_to :receipt

  validates :name, presence: true
  validates :amount, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
