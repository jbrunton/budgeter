class SyncResult
  attr_reader :statement
  attr_reader :transaction
  attr_reader :processed
  attr_reader :stored

  def initialize(attrs)
    @statement = attrs[:statement]
    @transaction = attrs[:transaction]
    @processed = attrs[:processed]
    @stored = attrs[:stored]
  end
end
