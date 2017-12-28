class CreditCardParser
  PREV_BALANCE_REGEX = /^BALANCE FROM PREVIOUS STATEMENT.*£((?:\d{1,3},)*\d{1,3}\.\d{2})/
  NEW_BALANCE_REGEX = /^NEW BALANCE.*£((?:\d{1,3},)*\d{1,3}\.\d{2})/
  DATE_RANGE_SPAN_YEARS = /^(\d{2} \p{L}+ \d{4}) - (\d{2} \p{L}+ \d{4})$/
  DATE_RANGE_SAME_YEAR = /^(\d{2} \p{L}+) - (\d{2} \p{L}+ \d{4})$/
  CARD_NUMBER_REGEX = /^\d{4} \d{4} \d{4} (\d{4})$/

  def initialize(project)
    @project = project
  end

  def parse(file)
    reader = PDF::Reader.new(file)

    candidate_transactions = []

    previous_balance = nil
    new_balance = nil
    lines = reader.pages.map { |page| page.text.split("\n").map{ |line| line.strip } }.flatten

    account_name = nil
    lines.each_with_index do |line, index|
      match = CARD_NUMBER_REGEX.match(line)
      if match
        account_name = "**** **** **** #{match[1]}"
        lines.delete_at(index)
        break
      end
    end

    lines.each_with_index do |line, index|
      match = PREV_BALANCE_REGEX.match(line)
      if match
        puts "Matched previous balance: #{line}"
        previous_balance = BigDecimal.new(match[1].tr(',', ''))
        lines.delete_at(index)
        break
      end
    end

    lines.each_with_index do |line, index|
      match = NEW_BALANCE_REGEX.match(line)
      if match
        puts "Matched new balance: #{line}"
        new_balance = BigDecimal.new(match[1].tr(',', ''))
        lines.delete_at(index)
        break
      end
    end

    date_range_start = nil
    date_range_end = nil
    lines.each_with_index do |line, index|
      match = DATE_RANGE_SAME_YEAR.match(line)
      if match
        puts "Matched date range: #{line}"
        date_range_end = Date.parse(match[2])
        date_range_start = Date.parse("#{match[1]} #{date_range_end.year}")
        lines.delete_at(index)
        break
      end
      match = DATE_RANGE_SPAN_YEARS.match(line)
      if match
        puts "Matched date range: #{line}"
        date_range_start = Date.parse(match[1])
        date_range_end = Date.parse(match[2])
        lines.delete_at(index)
        break
      end
    end

    if account_name.nil?
      raise "Unable to parse card number"
    end

    if date_range_start.nil? || date_range_end.nil?
      raise "Unable to parse date range."
    end

    if previous_balance.nil?
      raise "Unable to parse previous balance."
    end

    if new_balance.nil?
      raise "Unable to parse new balance."
    end

    account = @project.accounts.find_or_initialize_by(name: account_name)
    if account.new_record?
      account.account_type = 'credit_card'
      account.save
    end

    current_balance = previous_balance
    lines.each do |line|
      attrs = TransactionParser.new(line, date_range_start).parse
      if attrs
        current_balance += attrs[:value]
        attrs[:balance] = current_balance
        candidate_transactions << account.transactions.build(attrs)
      else
        puts "Ignoring: " + line
      end
    end

    if current_balance != new_balance
      raise "Error: computed new balance (#{current_balance}) != stated new balance (#{new_balance})"
    end

    if date_range_start.year != date_range_end.year
      candidate_transactions.each do |t|
        # we're at the Dec-Jan cutover, so update years for Jan transactions
        if t.date.month == 1
          t.date = t.date.change(year: date_range_end.year)
        end
      end
    end

    duplicate_transactions = []
    imported_transactions = []
    candidate_transactions.group_by{ |t| t.date }.each do |date, transactions_on_date|
      existing_transactions_on_date = account.transactions.where(date: date)
      if existing_transactions_on_date.count > 0
        duplicate_transactions_for_date = []
        transactions_on_date.each do |t|
          e = existing_transactions_on_date.select{ |e| e.sha == t.sha }.first
          duplicate_transactions_for_date << e unless e.nil?
        end
        if duplicate_transactions_for_date.length > 0
          if duplicate_transactions_for_date.count != existing_transactions_on_date.count
            raise "Error: some duplicate transactions detected for #{date}"
          end
        end
        duplicate_transactions.concat(transactions_on_date)
      else
        transactions_on_date.each_with_index do |t, index|
          t.date_index = index
          t.save
        end
        imported_transactions.concat(transactions_on_date)
      end
    end

    {
      account: account,
      imported_transactions: imported_transactions,
      duplicate_transactions: duplicate_transactions
    }
  end

  class TransactionParser
    INTEGER_CHARS = ('0'..'9').to_a
    DECIMAL_CHARS = ['.', ','].concat(INTEGER_CHARS)
    DATE_REGEX = /^\d{2}\s\p{L}{3}/

    def initialize(line, date_range_start)
      @line = line
      @date_range_start = date_range_start
      @whole_line = line
    end

    def parse
      value = parse_value
      return nil if value.nil?

      # transaction date
      return nil if parse_date.nil?

      # posting date
      date = parse_date
      return nil if date.nil?

      # skip whatever this number is..
      parse_integer

      begin
        attrs = {
          value: BigDecimal.new(value),
          date: Date.parse("#{date} #{@date_range_start.year}"),
          description: @line
        }
        puts "Parsed: #{@whole_line}"
        puts " as: " + attrs.to_s
        attrs
      rescue
        puts "Failed to parse: #{@whole_line}"
        nil
      end
    end

private

    def parse_value
      value = ''
      if @line.last == '-'
        negative = true
        @line = @line[0..-2].strip
      else
        negative = false
      end
      while DECIMAL_CHARS.include?(@line.last)
        value << @line.last unless @line.last == ','
        @line = @line[0..-2]
      end
      value = value.reverse
      value = '-' + value if negative
      value.length > 0 ? value : nil
    end

    def parse_date
      match = DATE_REGEX.match(@line)
      if match
        date = match[0]
        @line = @line[match[0].length..-1].strip
        date
      else
        nil
      end
    end

    def parse_integer
      value = ''
      while INTEGER_CHARS.include?(@line.first)
        value << @line.first
        @line = @line[1..-1].strip
      end
      value.length > 0 ? value : nil
    end
  end
end