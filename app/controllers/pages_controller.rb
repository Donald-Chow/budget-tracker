class PagesController < ApplicationController
  def dashboard
    @bar_chart_data = [
      {
        name: "Amount",
        data: Category.all.each_with_object({}) do |category, hash|
          amount = category.items.sum(:amount) > category.budget ? category.budget : category.items.sum(:amount)
          hash[category.name] = amount
        end
      },
      {
        name: "Over Budget",
        data: Category.all.each_with_object({}) do |category, hash|
          amount = category.items.sum(:amount) > category.budget ? category.items.sum(:amount) - category.budget : 0
          hash[category.name] = amount
        end
      }
    ]
    @items = Item.all
  end
end
