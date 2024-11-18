class Receipt < ApplicationRecord
  has_many :items, dependent: :destroy
  has_one_attached :photo

  validates :store, presence: true
  validates :date, presence: true

  accepts_nested_attributes_for :items, allow_destroy: true
end
