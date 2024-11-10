class PagesController < ApplicationController
  include ChartDataHelper

  def dashboard
    @pie_chart_data = Item.all.joins(:category).group("categories.name").sum(:amount)
    @bar_chart_data = bar_chart_data(Category.all)
  end
end
