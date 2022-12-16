

def filtered_rows_delete()
  @table_data_hash_array.delete(row)
end




















































def push_filtered_rows_to_table()
  filtered_hash = {}
  @joined_column_titles.each do |column|
    filtered_hash["#{column}"] = row["#{column}"]
  end
  @filtered_table.push(filtered_hash)
end

check_rows_by_where_filter(method(:push_filtered_rows_to_table(row)))
check_rows_by_where_filter(method(:delete_filtered_rows(row)))



def check_rows_by_where_filter(filtered_rows_function)
  @table_data_hash_array.each do |row|
    i = 0
    while i < @where_query.length
      @where_query_not_match = false
      where_column_value = row["#{@where_query[i]}"]
      where_criteria_value = @where_query[i+1]

      if where_column_value != where_criteria_value
        @where_query_not_match = true
        break
      end
      i += 2
    end
    if @where_query_not_match
      next
    end

    filtered_rows_function.call

  end
end































#  filter_table_where:
# @table_data_hash_array.each do |row|
#   i = 0
#   while i < @where_query.length
#     @where_query_not_match = false
#     where_column_value = row["#{@where_query[i]}"]
#     where_criteria_value = @where_query[i+1]

#     if where_column_value != where_criteria_value
#       @where_query_not_match = true
#       break
#     end
#     i += 2
#   end
#   if @where_query_not_match
#     next
#   end

#   filtered_hash = {}
#   @joined_column_titles.each do |column|
#     filtered_hash["#{column}"] = row["#{column}"]
#   end
#   @filtered_table.push(filtered_hash)

# end

# # filtered_rows_function =

# # # delete table value:
# # @table_data_hash_array.each do |row|
# #   i = 0
# #   while i < @where_query.length
# #     @where_query_not_match = false
# #     where_column_value = row["#{@where_query[i]}"]
# #     where_criteria_value = @where_query[i+1]

# #     if where_column_value != where_criteria_value
# #       @where_query_not_match = true
# #       break
# #     end
# #     i += 2
# #   end
# #   if @where_query_not_match
# #     next
# #   end

# #   @table_data_hash_array.delete(row)
# # # end
