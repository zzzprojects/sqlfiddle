SQL Fiddle
==========

##About

See [the SQL Fiddle about page](http://sqlfiddle.com/about.html) page for background on the site.

## Getting the project up and running

Fork the code on github to a local branch for youself.  

If you haven't already got [Maven](http://maven.apache.org), install it now.

From the root of your working copy, run this:

    mvn clean install 

Once everything downloads and builds, the zip will be ready under target/sqlfiddle.zip. Unzip this, cd into target/sqlfiddle, then type "./startup.sh". When the system is ready, you'll see this on the console:

    OpenIDM ready
    
You can now access your local server at [localhost:8080/sqlfiddle](http://localhost:8080/sqlfiddle).

You should now have a functional copy of SQL Fiddle running locally.  Out of the box, the only database "servers" you have are SQLite instances (since those actually run in your browser).  Setting up others requires separate work for each one (and isn't really necessary for most development work).

I'm happy to entertain pull requests!

Thanks, 
Jake Feasel
