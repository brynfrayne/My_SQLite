MySQLite
MySQLite is a simple database management system that allows users to perform various operations such as SELECT, INSERT, UPDATE, and DELETE. It supports only one JOIN and multiple WHERE conditions per request.

Features
FROM: Specify the table to be used for the request.
SELECT: Select specific columns from the table.
WHERE: Filter the results based on certain criteria.
JOIN: Join two tables on a common column.
ORDER: Sort the results based on a specified column.
INSERT: Insert new data into the table.
UPDATE: Update existing data in the table.
DELETE: Delete data from the table.
RUN: Execute the request.
Usage
To use MySQLite, create an instance of the MySqliteRequest class and call the various methods to build the request. The run method will execute the request and return the results.

request = MySqliteRequest.new
request = request.from('students.db')
request = request.select('name', 'email')
request = request.where('grade', 'A')
request.run
MySQLite CLI
MySQLite also includes a Command Line Interface (CLI) for interacting with the database through the terminal. To use the CLI, run the my_sqlite_cli.rb file and enter requests in the following format:

SELECT * FROM students.db;
INSERT INTO students.db VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
UPDATE students.db SET grade = 'B' WHERE name = 'Jane';
DELETE FROM students.db WHERE name = 'John';
Note
MySQLite saves and loads the database from a file, so all changes made through the CLI or MySqliteRequest class will be persisted between sessions.
