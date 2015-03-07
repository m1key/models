module Models

  class Sold

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      "Sold #{value}"
    end

    def ==(another_sold)
      self.value == another_sold.value
    end

  end

end
