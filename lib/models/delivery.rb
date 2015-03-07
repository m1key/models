module Models

  class Delivery

    attr_reader :value
    attr_reader :id

    def initialize(id, value)
      @id = id
      @value = value
    end

    def to_s
      "Delivery #{value}"
    end

    def ==(another_delivery)
      self.value == another_delivery.value
    end

  end

end
