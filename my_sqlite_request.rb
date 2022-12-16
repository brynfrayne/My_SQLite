require 'CSV'

class MySqliteRequest
  def initialize
    @args_from_cli = false
    @left_table_column_name_adjusted = false
    @file_name = nil
    @select_request = []
    @delete_request = false
    @column_titles
    @insert_values = []
    @join_request = []
    @sort_query = []
    @update_values = []
    @where_query = []
    @where_query_not_match = false
  end

  def table_data_array_to_hash(column_titles, table)
    table_data_hash_array = []
    id = 0

    table.each do |row|

      hash = {}
      id += 1
      hash["id"] = id
      row.each_index do |i|
        if row[i] && row[i].match?(/\A\d+\z/)
          row[i] = row[i].to_i
        end
        hash["#{column_titles[i]}"] = row[i]
      end
      table_data_hash_array.push(hash)
    end

    if !column_titles.include?("id")
      column_titles.unshift("id")
    end

    return table_data_hash_array
  end

  def args_from_cli
    @args_from_cli = true
    return self
  end

  def from(table_name)
   # From Implement a from method which must be present on each request. From will take a parameter and it will be the name of the table. (technically a table_name is also a filename (.csv))
    @file_name = table_name
    return self
  end

  def select(column_name)
    # Select Implement a where method which will take one argument a string OR an array of string. It will continue to build the request. During the run() you will collect on the result only the columns sent as parameters to select :-).
    # @select_request = []
    if column_name.is_a?(Array)
      @select_request = column_name
    else
      @select_request.push(column_name)
    end
    return self
  end

  def where(column_name, criteria)
      # Where Implement a where method which will take 2 arguments: column_name and value. It will continue to build the request. During the run() you will filter the result which match the value.
    if !criteria.is_a?(Integer) && criteria.match?(/\A\d+\z/)
      criteria = criteria.to_i
    end
    @where_query.push(column_name)
    @where_query.push('=')
    @where_query.push(criteria)
    return self
  end

  def where_comparison_operator(comparison_operator, i)
    @where_comparison_operator = comparison_operator
    @where_query[1 + 3*i] = @where_comparison_operator
    return self
  end

  def join(column_on_db_a, filename_db_b, column_on_db_b)
    # Join Implement a join method which will load another filename_db and will join both database on a on column.
    @join_file_name = filename_db_b
    @join_table_arr = CSV.parse(File.read(filename_db_b))
    @join_column_titles = @join_table_arr.shift
    @join_table_data_hash_arr = table_data_array_to_hash(@join_column_titles, @join_table_arr)
    @join_request.push(column_on_db_a)
    @join_request.push(column_on_db_b)
    return self
  end

  def order(order = 'ASC', column_name)
    # Order Implement an order method which will received two parameters, order (:asc or :desc) and column_name. It will sort depending on the order base on the column_name.
    @sort_query.push(order)
    @sort_query.push(column_name)
    return self
  end

  def insert(table_name)
    # Insert Implement a method to insert which will receive a table name (filename). It will continue to build the request.
    @file_name = table_name
    return self
  end

  def values(data)
    # Values Implement a method to values which will receive data. (a hash of data on format (key => value)). It will continue to build the request. During the run() you do the insert.
    @insert_values = data
    return self
  end

  def update(table_name)
    # Update Implement a method to update which will receive a table name (filename). It will continue to build the request. An update request might be associated with a where request.
    @file_name = table_name
    return self
  end

  def set(data)
    # Set Implement a method to update which will receive data (a hash of data on format (key => value)). It will perform the update of attributes on all matching row. An update request might be associated with a where request.
    @update_values = data
    return self
  end

  def delete
    # Delete Implement a delete method. It set the request to delete on all matching row. It will continue to build the request. An delete request might be associated with a where request.
    @delete_request = true
    return self
  end

  def run
    if !File.file?(@file_name)
      puts "Error: Invalid File"
      return self
    end

    @table_data_arr = CSV.parse(File.read(@file_name))
    @column_titles = @table_data_arr.shift

    @table_data_array_with_hashes = table_data_array_to_hash(@column_titles, @table_data_arr)

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

    if @update_values.length > 0
      update_values_in_data_table()
      save_updated_table_to_file(@file_name, "w")
    end

    if @delete_request
      delete_table_value()
      save_updated_table_to_file(@file_name, "w")
    end

    if @insert_values.length > 0
      insert_values_in_table()
      save_updated_table_to_file(@file_name, "w")
    end
    if @select_request.length > 0
      if @args_from_cli
        print_table()
      else
        puts "#{@table_data_array_with_hashes}"
      end
    end
    return
  end

  def save_updated_table_to_file(file, mode)
    CSV.open(file, mode) do |csv|
      csv << @column_titles
      @table_data_array_with_hashes.each_with_index do |row, i|
        array_row = convert_hash_to_array(row, i)
        csv << array_row
      end
    end
  end

  def convert_hash_to_array(hash, i)
    array = []

    @column_titles.each do |value|
      array.push(hash["#{value}"])
    end

    return array
  end

  def print_table()

    if @select_request[0] == '*'
      @select_request = @column_titles
    end

    @select_request.each_with_index do |column, i|
      if i == @select_request.length - 1
        print "#{column}"
      else
      print "#{column}|"
      end
    end
    print "\n"

    @table_data_array_with_hashes.each do |row|
      @select_request.each_with_index do |column, i|
        if i == @select_request.length - 1
          print "#{row["#{column}"]}"
        else
          print "#{row["#{column}"]}|"
        end
      end
      print "\n"
    end
  end

  def insert_values_in_table()

    insert_keys = @insert_values.keys

    if !insert_keys.include?("#{"id"}")
      @insert_values["id"] = @table_data_array_with_hashes.length+1
      insert_keys.push("id")
    end

    @column_titles.each do |column|
      if !insert_keys.include?(column.to_sym)
        @insert_values[:"#{column}"] = nil
      end
    end

    @table_data_array_with_hashes.push(@insert_values)
  end

  def delete_table_value()

    if @where_query.length > 0

      @table_data_array_with_hashes.reverse_each do |row|
        i = 0

        while i < @where_query.length
          @where_query_not_match = false
          where_column_value = row["#{@where_query[i]}"]
          where_comparison_operator = @where_query[i+1]
          where_criteria_value = @where_query[i+2]

          if !compare(where_comparison_operator, where_column_value, where_criteria_value)
            @where_query_not_match = true
            break
          end
          i += 3
        end
        if @where_query_not_match
          next
        end
        @table_data_array_with_hashes.delete(row)
      end

    else # deletes every row
      @table_data_array_with_hashes.reverse_each do |row|
        @table_data_array_with_hashes.delete(row)
      end
    end

  end

  def update_values_in_data_table()

    update_keys = @update_values.keys

    if @where_query.length > 0

      @table_data_array_with_hashes.each do |row|

        where_column_value = row["#{@where_query[0]}"]
        where_comparison_operator = @where_query[1]
        where_criteria_value = @where_query[2]

        if compare(where_comparison_operator, where_column_value, where_criteria_value)
          update_keys.each do |key|
            row["#{key}"] = @update_values["#{key}"]
          end
        end
      end

    else
      @table_data_array_with_hashes.each do |row|

        update_keys.each do |key|
          row["#{key}".to_sym] = @update_values["#{key}"]
        end
      end

    end

  end

  def filter_table_by_select()
    filtered_set = []

    @table_data_array_with_hashes.each do |row|
      filtered_hash = {}

      @select_request.each do |column|
        filtered_hash["#{column}"] = row["#{column}"]
      end
      filtered_set.push(filtered_hash)
    end

    @table_data_array_with_hashes = filtered_set
  end

  def sort_table()

    if @sort_query[0] == 'ASC'
      @table_data_array_with_hashes = @table_data_array_with_hashes.sort_by{|a|

        if !a["#{@sort_query[1]}"].is_a?(Integer)
          a["#{@sort_query[1]}"].downcase

        else
          a["#{@sort_query[1]}"]
        end
      }

    elsif @sort_query[0] == 'DESC'
      @table_data_array_with_hashes = @table_data_array_with_hashes.sort_by{|a|
        if !a["#{@sort_query[1]}"].is_a?(Integer)
          a["#{@sort_query[1]}"].downcase

        else
          a["#{@sort_query[1]}"]
        end
      }.reverse

    end
  end

  def compare(comparison, a, b)
    case comparison
    when '='
      return a == b
    when'!='
      return a != b
    when '>'
      return a > b
    when '>='
      return a>=b
    when '<'
      return a < b
    when '<='
      return a <= b
    end
  end


  def filter_table_by_where_condition()

    @filtered_table = []

    @table_data_array_with_hashes.each do |row|
      i = 0

      while i < @where_query.length

        @where_query_not_match = false
        where_column_value = row["#{@where_query[i]}"]
        where_comparison_operator = @where_query[i+1]
        where_criteria_value = @where_query[i+2]

        if !compare(where_comparison_operator, where_column_value, where_criteria_value)
          @where_query_not_match = true
          break
        end
        i += 3
      end

      if @where_query_not_match
        next
      end

      filtered_hash = {}

      @column_titles.each do |column|
        filtered_hash["#{column}"] = row["#{column}"]
      end

      @filtered_table.push(filtered_hash)
    end
    @table_data_array_with_hashes = @filtered_table

  end

  def join_tables()

    join_table = []
    left_table_column = @join_request[0].slice!(@join_request[0].rindex('.')+1..-1)
    right_table_column = @join_request[1].slice!(@join_request[1].rindex('.')+1..-1)

    @table_data_array_with_hashes.each do |row|

      @left_table_column_name_adjusted = false
      left_table_value = row["#{left_table_column}"]

      @join_table_data_hash_arr.each do |join_table_row|

        right_table_value = join_table_row["#{right_table_column}"]

        if left_table_value == right_table_value

          joined_rows = join_rows(row, join_table_row)
          join_table.push(joined_rows)
          @left_table_column_name_adjusted = true
          # break  --- break is only needed if you want to only match left table for one value on right & ignore any other possible matches
        end
      end
    end

    @new_join_table_file = @file_name + '_join_' + @join_file_name
    @table_data_array_with_hashes = join_table


    @column_titles.each_index do |i|
      @column_titles[i] = "#{@file_name}.#{@column_titles[i]}"
    end

    @join_column_titles.each_index do |i|
      @join_column_titles[i] = "#{@join_file_name}.#{@join_column_titles[i]}"
    end

    @joined_column_titles = @column_titles.concat(@join_column_titles)
    @column_titles = @joined_column_titles

  end

  def join_rows(left_row, right_row)

    left_keys = left_row.keys #array of left table keys
    left_key_map = {}

    right_keys = right_row.keys #array of right table keys
    right_key_map = {}
    if !@left_table_column_name_adjusted

      left_keys.each_index do |i|
        left_key_map["#{left_keys[i]}"] = "#{@file_name}.#{left_keys[i]}"
      end

      left_row.transform_keys!{ |k| left_key_map[k]}
    end

    right_keys.each_index do |i|
      right_key_map["#{right_keys[i]}"] = "#{@join_file_name}.#{right_keys[i]}"
    end

    right_row.transform_keys!{ |k| right_key_map[k]}

    joined_rows = left_row.merge(right_row)
    return joined_rows

  end

end
request = MySqliteRequest.new
# request = request.from('students.csv')
# request = request.delete
# request = request.from('nba_players_test.csv')
request = request.from('nba_test_1.csv')
request = request.join('nba_test_1.csv.Player', 'nba_test_2.csv', 'nba_test_2.csv.name')
# request = request.update('nba_test_2.csv')
# request = request.insert('students.csv')
# request = request.values({:name=>"Jiimmy Jo",:email=>"janejane@gmail.com", :grade=>"A-", :blog=>"https://blog.jimsspace.com"})
# request = request.set({"name"=>"Bryn Frayne","year_start"=>"2001","year_end"=>"2004","position"=>'C',"height"=>'6-2',"weight"=>'190',"birth_date"=>'May 30,1991',"college"=>'Camosun College'})
# request = request.where('name','John')
# request = request.where(/'nba_players_test.csv.height','180')
# request = request.where('email', 'jane@johndoe.com')
# request = request.select('*')
# request = request.select(['nba_players.csv.Player', 'nba_player_data.csv.college'])
# request = request.select(['email', 'blog'])
# request = request.order('DESC', 'email')

# request = request.join('nba_players_test.csv.Player', 'nba_player_data.csv', 'nba_player_data.csv.name')
# request = request.where('nba_players_test.csv.weight', 77)
# request = request.where('nba_players.csv.born', '1921')
print request.run
# request.run









# request = MySqliteRequest.new
# request = request.from('students.csv')
# request = request.select('*')
# request = request.select('name')
# request = request.where('weight', '180')
# request = request.join('weight', 'test_johnny.csv', 'weight')
# request = request.order('DESC', 'name')
# puts request.run
# print MySqliteRequest.from('students.csv').select('*').run


# came from line 151? just below if !where_query_match:
  # @where_query.each_index do |i|
            # if row[:"#{@where_query[0]}"] != @where_query[1]
            #   next
            # end
        # end

        # if there is a where request, check if the row's value matches the criteria
        # if @where_query.length > 0 && row[:"#{@where_query[0]}"] != @where_query[1]
        #   next
        # end



          # def filter_table_data()
  #   puts "#{@where_query}"
  #   matches_from_right_table = []
  #   @@filtered_table = []


  #   @table_data_array_with_hashes.each do |row|

  #     # go through the where request and filter based on every where request passed in
  #     if @where_query.length > 0
  #       i = 0
  #       while i < @where_query.length
  #         @where_query_not_match = false
  #         if row[:"#{@where_query[i]}"] != @where_query[i+1]
  #           @where_query_not_match = true
  #           break
  #         end
  #         i += 2
  #       end
  #     end

  #     if @where_query_not_match
  #       next
  #     end

  #     # if there is a join request
  #     if @join_request.length > 0
  #       left_table_value = row[:"#{join_query[0]}"]
  #       @join_table_data_hash_arr.each do |join_table_row|
  #         if join_table_row[:"#{@join_request[1]}"] == left_table_value && !matches_from_right_table.include?(join_table_row)
  #           matches_from_right_table.push(join_table_row)
  #           join_query_match = true
  #         end
  #       end
  #     end

  #     if @join_request.length > 0 && !join_query_match
  #       next
  #     end
  #     puts "does it make ithere??????????"
  #     filtered_hash = {}
  #     puts "184: #{@select_request}"

  #     @select_request.each do |column|
  #       filtered_hash[:"#{column}"] = row[:"#{column}"]
  #     end
  #     @@filtered_table.push(filtered_hash)
  #   end

  #   joined_rows = filter_matching_rows(matches_from_right_table)
  #   joined_rows.each do |row|
  #     @@filtered_table.push(row)
  #   end

  #   if @sort_query.length > 0
  #     if @sort_query[0] == 'ASC'
  #       @@filtered_table = @@filtered_table.sort_by{|a| a[:sort_value]}
  #     elsif @sort_query[1] == 'DESC'
  #       @@filtered_table = @@filtered_table.sort_by{|a| a[:sort_value]}.reverse
  #     end
  #   end

  # end


  # def filter_matching_rows(table)
    #   matched_table = []
    #   table.each do |row|
    #     matched_columns  = {}
    #     @select_request.each do |column_title|
    #       if row[:"#{column_title}"]
    #         matched_columns[:"#{column_title}"] = row[:"#{column_title}"]
    #       end
    #     end
    #     matched_table.push(matched_columns)
    #   end
    #   return matched_table
    # end