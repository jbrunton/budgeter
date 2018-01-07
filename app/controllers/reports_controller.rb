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
        month_spend = @project.sum_category(category, date, params[:account_ids])
        month_spend < 0 ? -month_spend.to_f : 0
      end
      builder.number({ label: category }, category_spend_data) if category_spend_data.any?{ |value| value > 0 }
    end

    render json: builder.build
  end

  def balance
    today = Date.today
    @default_start_date = today - 180.days
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
    @default_start_date = (today - 180.days).beginning_of_month
    @default_end_date = today
  end

  def income_outgoings_data
    first_date = Date.parse(params[:from_date])
    last_date = Date.parse(params[:to_date])

    dates = DateRange.new(first_date, last_date, true).to_a

    categories = @project.categories

    income_by_month = dates.map do |date|
      categories.map do |category|
        total = @project.sum_category(category, date, params[:account_ids])
        total > 0 ? total : 0
      end.reduce(:+)
    end

    spend_by_month = dates.map do |date|
      categories.map do |category|
        total = @project.sum_category(category, date, params[:account_ids])
        total < 0 ? total : 0
      end.reduce(:+)
    end

    net_income_by_month = [income_by_month, spend_by_month].transpose.map(&:sum)

    builder = DataTableBuilder.new
    builder.column({ type: 'date', label: 'Date' }, dates.map{ |d| serialize_date(d) })
    builder.number({ label: 'Income' }, income_by_month)
    builder.number({ label: 'Spend' }, spend_by_month)
    builder.number({ label: 'Net' }, net_income_by_month)

    render json: builder.build
  end

private
  def set_project
    @project = Project.find(params[:id])
  end
end