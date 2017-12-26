class CreditCardParser
  DATE_REGEX = '\d{2}\s\w{3}'
  TRANSACTION_SUFFIX_REGEX = /\d+\.\d{2}$/
  TRANSACTION_REGEX = /\s*(#{DATE_REGEX})\s+#{DATE_REGEX}\s+\d+\s+(.*)/

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
        suffix_match = TRANSACTION_SUFFIX_REGEX.match(line)
        if suffix_match
          val = suffix_match[0]
          match = TRANSACTION_REGEX.match(line.slice(0, line.length-val.length))
          if match
            year = 2017
            date = Date.parse("#{match[1]} #{year}")
            desc = match[2].strip
            imported_transactions << account.transactions.build({
              date: date,
              description: desc,
              value: val
            })
          end
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
end