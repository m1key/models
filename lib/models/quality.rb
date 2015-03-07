module Models

  class Quality

    attr_reader :value
    attr_reader :id

    def initialize(id, value)
      @value = value
      @id = id
    end

    def to_s
      "Quality #{value}"
    end

    def ==(another_quality)
      self.value == another_quality.value
    end

  end

end
