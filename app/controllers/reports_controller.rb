class ReportsController < ApplicationController
  before_action :set_project

  def spend
    current_month = @project.transactions.first.date.at_beginning_of_month
    last_date = @project.transactions.last.date

    categories = Transaction.where(project: @project)
      .group(:predicted_category)
      .sum(:value)
      .sort_by { |_, v| v }
      .to_h

    @data = [['Month'].concat(categories.map{ |k, _| k })]
    while current_month < last_date
      next_month = current_month.next_month
      row = [current_month.strftime('%b %Y')]
      categories.each do |category, _|
        month_spend = @project.transactions.within_month(current_month).where(predicted_category: category).sum(:value)
        row << (month_spend < 0 ? -month_spend.to_f : 0)
      end
      @data << row
      current_month = next_month
    end
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end