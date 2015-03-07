module Models

  class Duration

    attr_reader :value, :id

    def initialize(id, value)
      @id = id
      @value = value
    end

    def to_s
      "Duration #{value}"
    end

    def ==(another_duration)
      self.value == another_duration.value
    end

  end

end
