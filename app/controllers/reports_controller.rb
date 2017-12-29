class ReportsController < ApplicationController
  before_action :set_project

  def spend
    current_month = @project.transactions.first.date.at_beginning_of_month
    last_date = @project.transactions.last.date

    categories = Transaction.where(account: @project.accounts)
      .group('coalesce(category, predicted_category)')
      .sum(:value)
      .sort_by { |_, v| v }
      .to_h

    @data = [['Month'].concat(categories.map{ |k, _| k })]
    while current_month < last_date
      next_month = current_month.next_month
      row = [current_month.strftime('%b %Y')]
      categories.each do |category, _|
        month_spend = @project.transactions
          .within_month(current_month)
          .where('coalesce(category, predicted_category) = ?', category)
          .joins(:account)
          .sum("case accounts.account_type when 'credit_card' then -value else value end")
        row << (month_spend < 0 ? -month_spend.to_f : 0)
      end
      @data << row
      current_month = next_month
    end
  end

  def balance
    today = Date.today
    @default_start_date = today - 90.days
    @default_end_date = today
  end

  def balance_data
    first_date = Date.parse(params[:from_date])
    last_date = Date.parse(params[:to_date])

    dates = DateRange.new(first_date, last_date).to_a
    builder = BalanceReportBuilder.new(dates)
    @project.accounts.each { |account| builder.add_balances_from(account) }

    render json: builder.build(params[:account_ids] || [], params[:show_total]).to_json
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end