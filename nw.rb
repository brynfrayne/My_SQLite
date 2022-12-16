require 'CSV'

class MySqliteRequest

  def initialize
    @request_method = nil
    @file_name = nil
    @select_request
    @delete_request = []
    @data_table = []
    @column_titles
    @column_title_index_arr = []

  end

  def print_data_table()

    if @select_request.include?('*')
      @select_request = @column_titles
    end
    i = 0
    @select_request.each do |field|
      print "#{field}|"
    end
    print "\n"
    @table_data_arr.each do |row|
      row.each_index do |i|
        if @select_request.include?(@column_titles[i])
          if !row[i]
            print "nil|"
          else
            print "#{row[i]}|"
          end
        end
      end
      print "\n"
    end
  end

  def filter_rows()
    where_criteria = @where_request[0]
    where_value = @where_request[1]
    column_index_val = @column_titles.index(where_criteria)
    filtered_rows = []
    @table_data_arr.each_index do |i|
        if @table_data_arr[i][column_index_val] === where_value
          filtered_rows.push(@table_data_arr[i])
        end
      end
    @table_data_arr = filtered_rows
    return @table_data_arr
  end

  def update_rows()
    where_criteria = @where_request[0]
    where_value = @where_request[1]
    column_index_val = @column_titles.index(where_criteria)
    updated_row = []
    @table_data_arr.each_index do |i|
      if @table_data_arr[i][column_index_val] === where_value
        @set_request_column.each_index do |j|
          update_val_index = @column_titles.index(@set_request_column[j])
          @table_data_arr[i][update_val_index] = @set_request_values[j]
        end
      end
    end
    return @table_data_arr
  end

  def delete_rows()
    where_criteria = @where_request[0]
    where_value = @where_request[1]
    column_index_val = @column_titles.index(where_criteria)
    # puts "where_critera 80 - #{where_criteria}"
    # puts "81 - #{@column_titles}"
    updated_row = []
    # puts "81 - #{@table_data_arr}"
    @table_data_arr.each do |row|
      # puts "83 - #{column_index_val}"
      if row[column_index_val] == where_value
        @table_data_arr.delete(row)
      end
    end
    # @table_data_arr.each do |row|
    #   puts "82 - #{row[column_index_val]}"
    #   puts "83 - #{where_value}"
    #   if row[column_index_val] == where_value
    #     @table_data_arr.delete_at(i)
    #   end
    # end
    return @table_data_arr
  end

  def sort_rows()
    order_index_val = @column_titles.index(@order_request[0])
    if !@desc_order
      @table_data_arr.sort_by!{|a| a[order_index_val]}
    elsif @desc_order
      sorted_arr = @table_data_arr.sort_by!{|a| a[order_index_val]}
      @table_data_arr = sorted_arr.reverse()
    end
    return @table_data_arr
  end

  def join_tables()
    # we want to take create two table values
    puts "line 99  @join_request- #{@join_request}"
    @join_table_data_arr = CSV.parse(File.read(@join_request[0]))
    @join_column_titles = @join_table_data_arr.shift

    # puts "68 - @table_data_arr[@on_request[0]]: #{@table_data_arr[@on_request[0]]}"
    # puts "69 - @join_table_data_arr[@on_request[1]]: #{@join_table_data_arr[@on_request[1]]}"

    left_table_on_index = @column_titles.index(@left_on_request_value)
    right_table_on_index = @join_column_titles.index(@right_on_request_value)

    @match_table = []
    @column_titles = @column_titles + @join_column_titles

    @table_data_arr.each_index do |i|
      @join_table_data_arr.each_index do |j|
        # puts "83 - #{@table_data_arr[i][left_table_on_index]}"
        # puts "84 - #{@join_table_data_arr[j][right_table_on_index]}"

        # !! -- kind of works but needs to address values which match but are unique(ie matching names for different people)
        if @table_data_arr[i][left_table_on_index] == @join_table_data_arr[j][right_table_on_index]
          matching_row = (@table_data_arr[i] + @join_table_data_arr[j])
          # puts "76 match at:#{i}- #{matching_row}"
          @match_table.push(matching_row)
        end
      end
    end
    puts "line 126 - need to address matching values which are unique(ie two people with the same name)"
    @table_data_arr = @match_table
    return @table_data_arr
    # return @match_table
  end

  def select(column_name)
    @select_request = []
    if (column_name == nil || column_name.length == 0)
      puts "ERROR: Please choose another column"
    elsif column_name.is_a?(Array)
      @select_request = column_name
    else
      @select_request.push(column_name)
    end
    puts "this is @select_request: #{@select_request}"
    return self
  end

  def from(file_name)
    @file_name = file_name
    @request_method = 'from'
    puts "this is @file_name: #{@file_name}"
    return self
  end

  def delete(request)
    @delete_request = true
    return self
  end

  def insert(request)
    @request_method = 'insert'
    @file_name = request
    puts "@file_name = #{@file_name}"
    return self
  end

  def values(request)
    @values_request = request
    puts "line 121 - @values_request: #{@values_request}"
    return self
  end

  def update(request)
    @request_method = 'update'
    @file_name = request
    return self
  end

  def set(request)
    @set_request = request
    @set_request_column = []
    @set_request_values = []
    @set_request.each_index do |i|
      if i % 2 == 0
        @set_request_column.push(@set_request[i])
      else
        @set_request_values.push(@set_request[i])
      end
    end
    return self
  end

  def where(request)
    @where_request = request
    puts "@where_request : #{@where_request}"
    return self
  end

  def join(request)
    @join_request = request
    puts "line 107 - @join_request:#{@join_request}"
    return self
  end

  def on(request)
    @on_request = request
    puts "line 127 - @on_request:#{@on_request}"
    @left_on_request_index = @on_request[0].rindex('.')
    @right_on_request_index = @on_request[1].rindex('.')
    @left_on_request_value = @on_request[0].slice!(@left_on_request_index+1..@on_request[0].length()-1)
    @right_on_request_value = @on_request[1].slice!(@right_on_request_index+1..@on_request[1].length()-1)
    puts "line 130 - #{@left_on_request_value} & #{@right_on_request_value}"
    return self
  end

  def order(request)
    @order_request = request
    return self
  end

  def desc_order()
    @desc_order = true
    return self
  end

  def run

    if !File.file?(@file_name[0])
      puts "Error: Invalid file"
      return self
    end

    @table_data_arr = CSV.parse(File.read(@file_name[0]))
    @column_titles = @table_data_arr.shift

    case @request_method
    when 'from'
      # puts "233 - #{@select_request}"
      if @select_request
        run_select
      elsif @delete_request
        run_delete
      end
    when 'insert'
      run_insert
    when 'update'
      run_update
    end
  end

  def run_select

    # if @select_request.include?('*')
    #   @select_request = @column_titles
    # end

    # join condition
    if @join_request
      join_tables()
    end

    # where condition
    if @where_request
      filter_rows()
    end

    if @order_request
      sort_rows()
    end
    puts "this is going to print some data....."
    return print_data_table()
  end

  def run_delete
    delete_rows()
    CSV.open(@file_name[0], "w") do |csv|
      csv << @column_titles
      @table_data_arr.each do |row|
        csv << row
      end
    end
  end

  def run_insert
    File.write(@file_name[0], @values_request.join(','), mode: "a")
    File.write(@file_name[0], "\n", mode: "a")
  end

  def run_update
    update_rows()
    CSV.open(@file_name[0], "w") do |csv|
      csv << @column_titles
      @table_data_arr.each do |row|
        csv << row
      end
    end
  end

end
request = MySqliteRequest.new
request = request.from(['nba_players.csv'])
request = request.select('Player')
request = request.where(['birth_state', 'Indiana'])
request.run

# def create_table(column_titles, data)
#   @data_table = []
#   id = 0
#   data.each do |row|
#     data_hash = {}
#     id += 1
#     data_hash[:id] = "#{id}"
#     row.each_index do |i|
#       # puts "this is row[#{i}]: #{row[i]}"
#       # puts "this is column_titles[#{i}]: #{column_titles[i]}"
#       data_hash[:"#{column_titles[i]}"] = "#{row[i]}"
#     end
#     @data_table.push(data_hash)
#   end
#   return @data_table
# end

