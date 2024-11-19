class Item < ApplicationRecord
  belongs_to :category
  belongs_to :receipt

  default_scope { joins(:receipt).where(receipts: { date: Date.current.beginning_of_month..Date.current.end_of_month }) }
end
