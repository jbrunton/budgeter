class IncomeOutgoingsReportBuilder
  include FormatHelper

  def initialize(dates, project, account_ids)
    @dates = dates
    @project = project
    @account_ids = account_ids
  end

  def build
    income_by_month = []
    spend_by_month = []

    categories = @project.categories

    @dates.each do |date|
      result_for_month = income_outgoings_for_month(date, categories)
      income_by_month << result_for_month[:income_for_month]
      spend_by_month << result_for_month[:spend_for_month]
    end

    net_income_by_month = [income_by_month, spend_by_month].transpose.map(&:sum)

    builder = DataTableBuilder.new
    builder.column({ type: 'date', label: 'Date' }, @dates.map{ |d| serialize_date(d) })
    builder.number({ label: 'Income' }, income_by_month)
    builder.number({ label: 'Spend' }, spend_by_month)
    builder.number({ label: 'Net' }, net_income_by_month)
    builder.build
  end

private
  def income_outgoings_for_month(date, categories)
    income_for_month = 0
    spend_for_month = 0
    categories.each do |category|
      total = @project.sum_category(category, date, @account_ids)
      if total > 0
        income_for_month += total
      else
        spend_for_month += total
      end
    end
    {
      income_for_month: income_for_month,
      spend_for_month: spend_for_month
    }
  end
end