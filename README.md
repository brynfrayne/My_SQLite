<h1>MySQLite</h1>
<p>MySQLite is a simple database management system that allows users to perform various operations such as SELECT, INSERT, UPDATE, and DELETE. It supports only one JOIN and multiple WHERE conditions per request.</p>
<h2>Features</h2>
<ul>
  <li>FROM: Specify the table to be used for the request.</li>
  <li>SELECT: Select specific columns from the table.</li>
  <li>WHERE: Filter the results based on certain criteria.</li>
  <li>JOIN: Join two tables on a common column.</li>
  <li>ORDER: Sort the results based on a specified column.</li>
  <li>INSERT: Insert new data into the table.</li>
  <li>UPDATE: Update existing data in the table.</li>
  <li>DELETE: Delete data from the table.</li>
  <li>RUN: Execute the request.</li>
</ul>
<h2>Usage</h2>
<p>To use MySQLite, create an instance of the <code>MySqliteRequest</code> class and call the various methods to build the request. The <code>run</code> method will execute the request and return the results.</p>
<pre><code>request = MySqliteRequest.new
request = request.from('students.db')
request = request.select('name', 'email')
request = request.where('grade', 'A')
request.run</code></pre>
<h2>MySQLite CLI</h2>
<p>MySQLite also includes a Command Line Interface (CLI) for interacting with the database through the terminal. To use the CLI, run the <code>my_sqlite_cli.rb</code> file and enter requests in the following format:</p>
<pre><code>SELECT * FROM students.db;
INSERT INTO students.db VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
UPDATE students.db SET grade = 'B' WHERE name = 'Jane';
DELETE FROM students.db WHERE name = 'John';</code></pre>
<h2>Note</h2>
<p>MySQLite saves and loads the database from a file, so all changes made through the CLI or <code>MySqliteRequest</code> class will be persisted between sessions.</p>
