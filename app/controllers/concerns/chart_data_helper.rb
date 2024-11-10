module ChartDataHelper
  extend ActiveSupport::Concern

  def bar_chart_data(categories)
    [
      {
        name: "Amount",
        data: categories.each_with_object({}) do |category, hash|
          amount = category.items.sum(:amount) > category.budget ? category.budget : category.items.sum(:amount)
          hash[category.name] = amount
        end
      },
      {
        name: "Over Budget",
        data: categories.each_with_object({}) do |category, hash|
          amount = category.items.sum(:amount) > category.budget ? category.items.sum(:amount) - category.budget : 0
          hash[category.name] = amount
        end
      }
    ]
  end
end
