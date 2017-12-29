class BalanceReportBuilder
  include FormatHelper

  def initialize(dates)
    @dates = dates
    @balances = {}
    @totals = dates.map{ |_| 0 }
  end

  def add_balances_from(account)
    @balances[account] = @dates.each_with_index.map do |date, index|
      balance = account.balance_on(date)
      balance *= -1 if account.account_type == 'credit_card'
      @totals[index] += balance
      balance
    end
    self
  end

  def build
    table_builder = DataTableBuilder.new
    table_builder.column({ id: 'date', type: 'date', label: 'Date' }, @dates.map{ |d| serialize_date(d) })
    @balances.each do |account, balances|
      table_builder.number({ label: account.name }, balances)
    end
    table_builder.number({ label: 'Total' }, @totals)
    table_builder.build
  end
end