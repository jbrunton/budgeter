class PdfStatementParser
  PREV_BALANCE_REGEX = /^BALANCE FROM PREVIOUS STATEMENT.*£((?:\d{1,3},)*\d{1,3}\.\d{2})/
  NEW_BALANCE_REGEX = /^NEW BALANCE.*£((?:\d{1,3},)*\d{1,3}\.\d{2})/
  DATE_RANGE_SPAN_YEARS = /^(\d{2} \p{L}+ \d{4}) - (\d{2} \p{L}+ \d{4})$/
  DATE_RANGE_SAME_YEAR = /^(\d{2} \p{L}+) - (\d{2} \p{L}+ \d{4})$/

  def initialize(account)
    @account = account
    @previous_balance = nil
    @new_balance = nil
    @date_range_start = nil
    @date_range_end = nil
  end

  def parse(file)
    reader = PDF::Reader.new(file)

    @lines = reader.pages.map { |page| page.text.split("\n").map{ |line| line.strip } }.flatten

    parse_balances
    validate_balances

    parse_date_range
    validate_date_range

    candidate_transactions = parse_transactions
    check_dates(candidate_transactions)

    TransactionImporter.new(@account).import(candidate_transactions)
  end

private

  def parse_balances
    match_line(PREV_BALANCE_REGEX) do |match, line|
      puts "Matched previous balance: #{line}"
      @previous_balance = BigDecimal.new(match[1].tr(',', ''))
    end

    match_line(NEW_BALANCE_REGEX) do |match, line|
      puts "Matched new balance: #{line}"
      @new_balance = BigDecimal.new(match[1].tr(',', ''))
    end
  end

  def match_line(regex, &block)
    @lines.each_with_index do |line, index|
      match = regex.match(line)
      if match
        block.call(match, line)
        @lines.delete_at(index)
        break
      end
    end
  end

  def parse_date_range
    match_line(DATE_RANGE_SAME_YEAR) do |match, line|
      puts "Matched date range: #{line}"
      @date_range_end = Date.parse(match[2])
      @date_range_start = Date.parse("#{match[1]} #{@date_range_end.year}")
    end
    match_line(DATE_RANGE_SPAN_YEARS) do |match, line|
      puts "Matched date range: #{line}"
      @date_range_start = Date.parse(match[1])
      @date_range_end = Date.parse(match[2])
    end
  end

  def validate_date_range
    if @date_range_start.nil? || @date_range_end.nil?
      raise "Unable to parse date range."
    end
  end

  def validate_balances
    if @previous_balance.nil?
      raise "Unable to parse previous balance."
    end

    if @new_balance.nil?
      raise "Unable to parse new balance."
    end
  end

  def parse_transactions
    candidate_transactions = []
    current_balance = @previous_balance
    @lines.each do |line|
      attrs = TransactionParser.new(line, @date_range_start).parse
      if attrs
        current_balance += attrs[:value]
        attrs[:balance] = current_balance
        candidate_transactions << @account.transactions.build(attrs)
      else
        puts "Ignoring: " + line
      end
    end

    if current_balance != @new_balance
      raise "Error: computed new balance (#{current_balance}) != stated new balance (#{@new_balance})"
    end

    candidate_transactions
  end

  def check_dates(candidate_transactions)
    if @date_range_start.year != @date_range_end.year
      candidate_transactions.each do |t|
        # we're at the Dec-Jan cutover, so update years for Jan transactions
        if t.date.month == 1
          t.date = t.date.change(year: @date_range_end.year)
        end
      end
    end
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
      negative = parse_value_sign
      value = parse_value_digits
      value = '-' + value if negative
      value.length > 0 ? value : nil
    end

    def parse_value_sign
      if @line.last == '-'
        @line = @line[0..-2].strip
        true
      else
        false
      end
    end

    def parse_value_digits
      value = ''
      while DECIMAL_CHARS.include?(@line.last)
        value << @line.last unless @line.last == ','
        @line = @line[0..-2]
      end
      value.reverse
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