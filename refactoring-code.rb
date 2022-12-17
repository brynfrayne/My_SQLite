str = "hello"
puts str.to_sym.class
# puts sym.class # Output: Symbol
puts str.class
# str2 = sym.to_s
# puts str2.class # Output: String
# puts sym.class







# def filter_table_by_where_condition()
#   @filtered_table = []

#   @table_data_array_with_hashes.each do |row|
#     i = 0

#     while i < @where_query.length
#       @where_query_not_match = false
#       where_column_value = row["#{@where_query[i]}"]
#       where_comparison_operator = @where_query[i+1]
#       where_criteria_value = @where_query[i+2]

#       if !compare(where_comparison_operator, where_column_value, where_criteria_value)
#         @where_query_not_match = true
#         break
#       end
#       i += 3
#     end

#     if @where_query_not_match
#       next
#     end

#     filtered_hash = {}

#     @column_titles.each do |column|
#       filtered_hash["#{column}"] = row["#{column}"]
#     end

#     @filtered_table.push(filtered_hash)
#   end
#   @table_data_array_with_hashes = @filtered_table
# end

# def compare(where_comparison_operator, where_column_value, where_criteria_value)
#   case where_comparison_operator
#   when '='
#     return where_column_value == where_criteria_value
#   when '>'
#     return where_column_value > where_criteria_value
#   when '>='
#     return where_column_value >= where_criteria_value
#   when '<'
#     return where_column_value < where_criteria_value
#   when '<='
#     return where_column_value <= where_criteria_value
#   when '!='
#     return where_column_value != where_criteria_value
#   when 'LIKE'
#     return where_column_value.include?(where_criteria_value)
#   end
# end
