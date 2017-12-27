class CreditCardParser
  PREV_BALANCE_REGEX = /^BALANCE FROM PREVIOUS STATEMENT.*£((?:\d{1,3},)*\d{1,3}\.\d{2})/
  NEW_BALANCE_REGEX = /^NEW BALANCE.*£((?:\d{1,3},)*\d{1,3}\.\d{2})/

  def initialize(project)
    @project = project
  end

  def parse(file)
    reader = PDF::Reader.new(file)

    account_name = 'Credit Card'
    account = @project.accounts.find_or_create_by(name: account_name)
    account.transactions.delete_all

    imported_transactions = []

    previous_balance = nil
    new_balance = nil

    lines = reader.pages.map { |page| page.text.split("\n").map{ |line| line.strip } }.flatten

    lines.each_with_index do |line, index|
      match = PREV_BALANCE_REGEX.match(line)
      if match
        previous_balance = BigDecimal.new(match[1].tr(',', ''))
        lines.delete_at(index)
        break
      end
    end

    lines.each_with_index do |line, index|
      match = NEW_BALANCE_REGEX.match(line)
      if match
        new_balance = BigDecimal.new(match[1].tr(',', ''))
        lines.delete_at(index)
        break
      end
    end

    if previous_balance.nil?
      raise "Unable to parse previous balance."
    end

    if new_balance.nil?
      raise "Unable to parse previous balance."
    end

    current_balance = previous_balance
    lines.each do |line|
      attrs = TransactionParser.new(line).parse
      if attrs
        current_balance += attrs[:value]
        attrs[:balance] = current_balance
        imported_transactions << account.transactions.build(attrs)
      else
        puts "Ignoring: " + line
      end
    end

    if current_balance != new_balance
      raise "Error: computed new balance (#{current_balance}) != stated new balance (#{new_balance})"
    end

    imported_transactions.group_by{ |t| t.date }.each do |_, transactions|
      transactions.each_with_index { |t, index| t.date_index = index }
      transactions.each { |t| t.save }
    end

    imported_transactions
  end

  class TransactionParser
    INTEGER_CHARS = ('0'..'9').to_a
    DECIMAL_CHARS = ['.', ','].concat(INTEGER_CHARS)
    DATE_REGEX = /^\d{2}\s\p{L}{3}/

    def initialize(line)
      @line = line
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
          date: Date.parse("#{date} 2016"),
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