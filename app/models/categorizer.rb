class Categorizer
  attr_reader :project
  attr_reader :training_transactions
  attr_reader :test_transactions
  attr_reader :score

  def initialize(project)
    @project = project
  end

  def preview(seed, ignore_words)
    partition_transactions(seed)

    classifier = StuffClassifier::Bayes.new('Transaction Classifier')
    classifier.ignore_words = ignore_words.map{ |s| s.chomp }
    @training_transactions.each do |t|
      classifier.train(t.category, t.description)
    end

    @test_transactions.each do |t|
      t.predicted_category = classifier.classify(t.description)
    end

    @score = Categorizer.score(@test_transactions)
  end

  def apply(seed, ignore_words)
    preview(seed, ignore_words)
    @test_transactions.each do |t|
      t.save
    end
  end

  def self.score(transactions)
    correct_count = transactions.select { |t| t.assess_prediction == :correct }.count
    incorrect_count = transactions.select { |t| t.assess_prediction == :incorrect }.count
    (correct_count.to_f * 100 / (incorrect_count + correct_count)).round
  end

private
  def partition_transactions(seed)
    categorised_transactions = @project.transactions.select{ |t| !t.category.blank? }
    transactions_by_category = categorised_transactions.group_by{ |t| t.category }
    training_transactions = []
    test_transactions = []
    transactions_by_category.each do |_, ts|
      head, *tail = ts
      training_transactions << head
      test_transactions.concat tail
    end

    test_transactions.shuffle!(random: Random.new(seed))

    target_test_size = (categorised_transactions.count * 0.3)
    while test_transactions.size > target_test_size + 1
      training_transactions << test_transactions.pop
    end

    @test_transactions = test_transactions
    @training_transactions = training_transactions
  end
end