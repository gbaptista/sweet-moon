module Logic
  Tables = {
    to_hash_or_array: ->(tuples) {
      indexes = tuples.map { |kv| kv[0] }

      is_array = true

      previous = 0.0

      indexes.each do |index|
        is_array = false unless index.is_a? Numeric
        is_array = false if index != previous + 1

        break unless is_array

        previous += 1
      end

      # TODO: How to handle empty?
      return tuples.map { |kv| kv[1] } if indexes.size.positive? && is_array

      result = {}

      tuples.each do |key_value|
        key, value = key_value
        result[key] = value
      end

      result
    }
  }
end
