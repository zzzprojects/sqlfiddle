SQL Fiddle
==========

##About

See [the SQL Fiddle about page](http://sqlfiddle.com/about.html) page for background on the site.

## Getting the project up and running

Fork the code on github to a local branch for youself.  

If you haven't already got [Maven](http://maven.apache.org), install it now.

From the root of your working copy, run this:

    mvn jetty:run

Once everything downloads and runs, the app will be running on [localhost:8080](http://localhost:8080).  Watch for this message in your console:

    [INFO] Started Jetty Server
    
You can now access your local server at [localhost:8080](http://localhost:8080/).

You should now have a functional copy of SQL Fiddle running locally.  Out of the box, the only database "servers" you have are SQLite instances (since those actually run in your browser).  Setting up others requires separate work for each one (and isn't really necessary for most development work).

The document root being served is src/main/webapp.  You can edit the files under there and see the changes immediately upon refresh (no need to restart the jetty server).

##Optional

You *should* set the Railo Admin passwords.  Here are the links to get to both admin contexts, once you have Jetty running:

[Local Railo Web Admin](http://localhost:8080/railo-context/admin/web.cfm)
[Local Railo Server Admin](http://localhost:8080/railo-context/admin/server.cfm)

The simplest thing to do would be to set the password just to "password" (no quotes).  This is the default password in the config.  If you choose to use another Railo admin password, you must set it in the file src/main/webapp/config/development/settings.cfm and update the CFAdminPassword.  Once you set the admin password, you don't need to do anything else in the Railo Administrator. 

I'm happy to entertain pull requests!

Thanks, 
Jake Feasel
