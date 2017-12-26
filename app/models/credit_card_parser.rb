class CreditCardParser
  def initialize(project)
    @project = project
  end

  def parse(file)
    reader = PDF::Reader.new(file)

    account_name = 'Credit Card'
    account = @project.accounts.find_or_create_by(name: account_name)
    account.transactions.delete_all

    imported_transactions = []

    start_time = DateTime.now

    reader.pages.each do |page|
      page.text.split("\n").each do |line|
        line = line.strip
        attrs = TransactionParser.new(line).parse
        if attrs
          imported_transactions << account.transactions.build(attrs)
        else
          puts "Ignoring: " + line
        end
      end
    end

    end_time = DateTime.now
    total_time = ((end_time - start_time) * 1.days).to_f
    puts "Parse time: #{total_time} seconds"

    imported_transactions.group_by{ |t| t.date }.each do |_, transactions|
      transactions.each_with_index { |t, index| t.date_index = index }
      transactions.each { |t| t.save }
    end

    imported_transactions
  end

  class TransactionParser
    INTEGER_CHARS = ('0'..'9').to_a
    DECIMAL_CHARS = ['.'].concat(INTEGER_CHARS)
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
      while DECIMAL_CHARS.include?(@line.last)
        value << @line.last
        @line = @line[0..-2]
      end
      value.length > 0 ? value.reverse : nil
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