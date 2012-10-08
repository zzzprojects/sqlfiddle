SQL Fiddle
==========

##About

See [the SQL Fiddle about page](http://sqlfiddle.com/about.html) page for background on the site.

## Getting the project up and running

Fork the code on github to a local branch for youself.  *git clone* and then from within your working copy, run this:

    mvn jetty:run

Once everything downloads and runs, the app will be running on [localhost:8080](http://localhost:8080).  The document root being served is src/main/webapp.

You'll want to set the Railo Admin password right away.  Here's the link to get there, once you have Jetty running:

[Local Railo Admin](http://localhost:8080/railo-context/admin/web.cfm)

Copy the file src/main/webapp/config/environment.cfm.example to src/main/webapp/onfig/environment.cfm

Copy the file src/main/webapp/config/design/settings.cfm.example to src/main/webapp/config/design/settings.cfm

Edit src/main/webapp/onfig/design/settings.cfm and update the CFAdminPassword value to be whatever you used for your Railo admin password.

You should now have a functional copy of SQL Fiddle running locally.  You won't have much in the way of database backends, of course, since setting those up requires separate work for each one (and isn't really necessary for most development work).

I'm happy to entertain pull requests!

Thanks, Jake
