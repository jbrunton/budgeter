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

    @data = [['Date'].concat(@project.accounts.map{ |a| a.name }).concat(['Total'])]
    while current_date < last_date
      row = [serialize_date(current_date)]

      account_balances = @project.accounts.map do |a|
        balance = a.balance_on(current_date).to_f
        {
          balance: a.account_type == 'credit_card' ? -balance : balance,
          account_type: a.account_type
        }
      end
      row.concat(account_balances.map{ |a| a[:balance] })

      total = account_balances
        .map{ |a| a[:balance] }
        .reduce(:+)
      row << total
      @data << row
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