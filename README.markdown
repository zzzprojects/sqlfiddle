#SQL Fiddle

##About

See [the SQL Fiddle about page](http://sqlfiddle.com/about.html) page for background on the site.

## Getting the project up and running

If you want to get this app running on your environment, here's how you do it.

1. Download and install the latest stable [Railo Server with Tomcat](http://www.getrailo.org/index.cfm/download/) for your environment

2. Remove the unneeded default files from the Railo ROOT folder:

        cd [your railo install base]/tomcat/webapps/ROOT

        ls -d * | grep -v WEB-INF | sudo xargs rm -rf

3. Clone your fork of this repository into some temporary, empty folder

4. Put this code into the Railo ROOT folder:

        cp -R sqlfiddle/* sqlfiddle/.git* sqlfiddle/.htaccess [your railo install base]/tomcat/webapps/ROOT/
        
5. Copy the file config/environment.cfm.example to config/environment.cfm

6. Copy the file config/design/settings.cfm.example to config/design/settings.cfm

7. Edit config/design/settings.cfm and update the CFAdminPassword value to be whatever you used for your Railo admin password (if you aren't using an Admin password, then it shouldn't matter what this is set to)

8. Download and install the latest [PostgreSQL server](http://www.postgresql.org/download/) for your environment

9. Create a new PostgreSQL database named sqlfiddle:

        createdb -U postgres -E UTF8 sqlfiddle
        
10. Run the database restore scripts db/schema.sql and db/data.sql in your new sqlfiddle database

11. Create new datasource connections from Railo to postgresql:
    Browse to http://localhost/railo-context/admin/web.cfm, login (if needed) and navigate to Services->Datasource
    Add a datasource named "sqlfiddle" of type "PostgreSQL".  Use the credentials you defined for your sqlfiddle database.
    Add another datasource named "sqlfiddle_pg1" of type "PostgreSQL". Use an account with admin privileges (such as "postgres"), connecting to the "postgres" database.
    
12. Setup a mail server for Railo:
    Browse to http://localhost/railo-context/admin/web.cfm, login (if needed) and navigate to Services->Mail
    Add an entry under Mail servers for an SMTP server you have access to. Don't worry if it doesn't actually work; it only matters that there is some defined here.
    
13. You should now have a minimally-functional copy of the app available at http://localhost/ (or, if you used a different port when you installed Railo/tomcat, then use that)
    *The only database type options that will be functional are PostgreSQL and SQLite; you'll have to install and configure the other backend database servers and add datasource connections (like sqlfiddle_mysql1) for each of those. I suggest just ignoring them unless you really want to work on something relating to them specifically.*
    
14. If you want to use the "View Sample Fiddle" option, you'll have to define your own samples.  Build them as normal, then when you have it ready copy the URL fragment (everything after the #!) and set it in the database table "sqlfiddle.db_types", under the column "sample_fragment".
    After you set this value, you'll have to reload the app to clear the cache: http://localhost/?reload=true
    
This should get you going! Good luck, and feel free to create an issue on my [GitHub repo](https://github.com/jakefeasel/sqlfiddle) if these instructions need work.

-- Jake Feasel, 07/15/2012