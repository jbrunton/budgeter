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
        row << month_spend.to_f
      end
      @data << row
      current_month = next_month
    end
    # @data = [
    #   ['Month',  'Rotten Tomatoes', 'IMDB'],
    #   ['Alfred Hitchcock (1935)', 8.4,         7.9],
    #   ['Ralph Thomas (1959)',     6.9,         6.5],
    #   ['Don Sharp (1978)',        6.5,         6.4],
    #   ['James Hawes (2008)',      4.4,         6.2]
    # ]
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end