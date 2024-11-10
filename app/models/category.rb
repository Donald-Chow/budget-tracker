class Category < ApplicationRecord
  has_many :items

  validates :name, presence: true
  validates :budget, numericality: { greater_than_or_equal_to: 0 }
end
