str = "hello"
puts str.to_sym.class
# puts sym.class # Output: Symbol
puts str.class
# str2 = sym.to_s
# puts str2.class # Output: String
# puts sym.class



def filter_table
  if @join_request.length > 0
    join_tables()
    save_updated_table_to_file(@new_join_table_file, "w+")

  end

  if @where_query.length > 0 && !(@update_values.length > 0) && !@delete_request
    filter_table_by_where_condition()
  end

  if @sort_query.length > 0
    sort_table()
  end

  if @select_request[0] != '*' && @select_request.length > 1
    filter_table_by_select()
  end
end


def filter_result_set
  join_query_match = false
  matched = []
  joined_rows = []

  @table_data_array_with_hashes.each do |row|

    next if @where_query.length > 0 && (row[:"#{@where_query[0]}"] != @where_query[1])

    if @join_query.length > 0
      left_table_join_value = row[:"#{@join_query[0]}"]
      @join_table_data_hash_arr.each do |join_table_row|
        right_table_join_value = join_table_row[:"#{@join_query[1]}"]
        if right_table_join_value == left_table_join_value && !matched.include?(join_table_row)
          matched.push(join_table_row)
          join_query_match = true
        end
      end
    end

    next if @join_query.length > 0 && join_query_match == false

    result = {}

    @select_query.each do |column|
      result[:"#{column}"] = row[:"#{column}"]
    end

    @result_set.push(result)
  end

  joined_rows = filter_matching_rows(matched)
  joined_rows.each {|hash| @result_set.push(hash)}

  if @sort_query.length > 0
    if @sort_query[0] == 'ASC'
      @result_set = @result_set.sort_by{ |hash| hash[:"#{@sort_query[1]}"] }
    end
    if @sort_query[0] == 'DESC'
      @result_set = @result_set.sort_by{ |hash| hash[:"#{@sort_query[1]}"] }.reverse
    end
  end
end


# def filter_table_by_where_condition()
#   @filtered_table = []

#   @table_data_array_with_hashes.each do |row|
#     i = 0

#     while i < @where_query.length
#       @where_query_not_match = false
#       where_column_left_table_join_valueue = row["#{@where_query[i]}"]
#       where_comparison_operator = @where_query[i+1]
#       where_criteria_left_table_join_valueue = @where_query[i+2]

#       if !compare(where_comparison_operator, where_column_left_table_join_valueue, where_criteria_left_table_join_valueue)
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

# def compare(where_comparison_operator, where_column_left_table_join_valueue, where_criteria_left_table_join_valueue)
#   case where_comparison_operator
#   when '='
#     return where_column_left_table_join_valueue == where_criteria_left_table_join_valueue
#   when '>'
#     return where_column_left_table_join_valueue > where_criteria_left_table_join_valueue
#   when '>='
#     return where_column_left_table_join_valueue >= where_criteria_left_table_join_valueue
#   when '<'
#     return where_column_left_table_join_valueue < where_criteria_left_table_join_valueue
#   when '<='
#     return where_column_left_table_join_valueue <= where_criteria_left_table_join_valueue
#   when '!='
#     return where_column_left_table_join_valueue != where_criteria_left_table_join_valueue
#   when 'LIKE'
#     return where_column_left_table_join_valueue.include?(where_criteria_left_table_join_valueue)
#   end
# end
