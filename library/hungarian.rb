matrix = [[57, 58, 4, 8],
          [89, 8, 76, 77],
          [21, 45, 2, 29],
          [71, 30, 26, 43]]


class Hungarian

  attr_reader :n
  def initialize(matrix)
    @matrix = matrix.map(&:dup)
    @n = @matrix.size
    @assigned_row = Array.new(n, nil)
    @assigned_column = Array.new(n, nil)
    @label_row = matrix.map(&:max)
    @label_column = Array.new(n, 0)

    kuhn_munkres
  end

  def assignation
    @assigned_row
  end

  def score
    @label_row.sum + @label_column.sum
  end

  def improve_matching(row, row_in_equal_tree, column_in_equal_tree)
    raise if row_in_equal_tree[row]
    row_in_equal_tree[row] = true
    (0...n).each do |column|
      next if column_in_equal_tree[column] || @matrix[row][column] != @label_row[row] + @label_column[column]

      column_in_equal_tree[column] = true
      if @assigned_column[column].nil? || improve_matching(@assigned_column[column], row_in_equal_tree, column_in_equal_tree)
        @assigned_column[column] = row
        @assigned_row[row] = column
        return true
      end
    end
    false
  end

  def improve_labels(row_in_equal_tree, column_in_equal_tree)
    delta = (0...n).flat_map do |row|
      next 100_000 unless row_in_equal_tree[row]

      (0...n).map do |column|
        next 100_000 if column_in_equal_tree[column]

        @label_row[row] + @label_column[column] - @matrix[row][column]
      end
    end.min
    (0...n).each do |row|
      @label_row[row] -= delta if row_in_equal_tree[row]
    end

    (0...n).each do |column|
      @label_column[column] += delta if column_in_equal_tree[column]
    end
  end

  def kuhn_munkres
    raise if @matrix[0].size != @matrix.size
    (0...n).each do |row|
      next if @assigned_row[row]

      loop do
        # warn [label_row, label_column].inspect
        row_in_equal_tree = Array.new(n, false)
        column_in_equal_tree = Array.new(n, false)
        break if improve_matching(row, row_in_equal_tree, column_in_equal_tree)

        improve_labels(row_in_equal_tree, column_in_equal_tree)
      end
    end
    [@assigned_row, @label_row.sum + @label_column.sum]
  end
end


hungarian = Hungarian.new(matrix)
puts hungarian.score
p hungarian.assignation