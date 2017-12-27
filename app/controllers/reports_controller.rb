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

  def balance
    first_date = @project.transactions.first.date
    current_date = first_date
    last_date = @project.transactions.last.date

    @data = [['Date', 'Balance']]
    while current_date < last_date
      current_balance_sum = @project.accounts.current.map { |a| a.balance_on(current_date) }.reduce(:+)
      credit_balance_sum = @project.accounts.credit_card.map{ |a| a.balance_on(current_date) }.reduce(:+)
      balance = (current_balance_sum || 0) - (credit_balance_sum || 0)
      @data << [serialize_date(current_date), balance.to_f]
      current_date = current_date.tomorrow
    end
  end

private
  def set_project
    @project = Project.find(params[:id])
  end

  def serialize_date(date)
    "Date('#{date.strftime('%Y-%m-%d')}')"
  end
end