class ReportsController < ApplicationController
  before_action :set_project

  include FormatHelper

  def spend
    today = Date.today
    @default_start_date = (today - 180.days).beginning_of_month
    @default_end_date = today
  end

  def spend_data
    categories = Transaction.where(account: @project.accounts)
      .group('coalesce(assigned_category, predicted_category)')
      .sum(:value)
      .sort_by { |_, v| v.abs }
      .map{ |category, _| category }
      .to_a

    first_date = Date.parse(params[:from_date])
    last_date = Date.parse(params[:to_date])
    dates = DateRange.new(first_date, last_date, true).to_a

    builder = DataTableBuilder.new
    builder.column({ type: 'date', label: 'Date' }, dates.map{ |d| serialize_date(d) })
    categories.each do |category|
      category_spend_data = dates.map do |date|
        month_spend = @project.transactions
          .within_month(date)
          .joins(:account)
          .where('coalesce(assigned_category, predicted_category) = ?', category)
          .where('account_id in (?)', params[:account_ids])
          .sum("case accounts.account_type when 'credit_card' then -value else value end")
        month_spend < 0 ? -month_spend.to_f : 0
      end
      builder.number({ label: category }, category_spend_data) if category_spend_data.any?{ |value| value > 0 }
    end

    render json: builder.build
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

  def income_outgoings
    today = Date.today
    @default_start_date = (today - 90.days).beginning_of_month
    @default_end_date = today
  end

  def income_outgoings_data
    first_date = Date.parse(params[:from_date])
    last_date = Date.parse(params[:to_date])

    dates = DateRange.new(first_date, last_date, true).to_a

    builder = DataTableBuilder.new
    builder.column({ type: 'date', label: 'Date' }, dates.map{ |d| serialize_date(d) })
    builder.number({ label: 'Income' }, dates.map{ |d| 1000 })

    render json: builder.build
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end