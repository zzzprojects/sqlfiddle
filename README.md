## Library Powered By

This library is powered by [Entity Framework Extensions](https://entityframework-extensions.net/?z=github&y=entityframework-plus)

<a href="https://entityframework-extensions.net/?z=github&y=entityframework-plus">
<kbd>
<img src="https://zzzprojects.github.io/images/logo/entityframework-extensions-pub.jpg" alt="Entity Framework Extensions" />
</kbd>
</a>

---

SQL Fiddle
==========

## THIS VERSION IS NOT IN USE ANY MORE

SQL Fiddle has been implemented with a new codebase - see https://github.com/jakefeasel/sqlfiddle2 for those details

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

## Usefull links

- [Website](http://sqlfiddle.com/)
- [Documentation](http://sqlfiddle.com/about.html)
- You can also consult SQL Fiddle questions on 
[Stack Overflow](https://stackoverflow.com/questions/tagged/sqlfiddle)

## Contribute

You want to help us? 
Your donation directly helps us maintaining and growing ZZZ Free Projects. We can’t thank you enough for your support.

### Why should I contribute to this free & open source library?
We all love free and open source libraries!
But there is a catch! Nothing is free in this world.
Contributions allow us to spend more of our time on: Bug Fix, Content Writing, Development and Support.

We NEED your help. Last year alone, we spent over **3000 hours** maintaining all our open source libraries.

### How much should I contribute?
Any amount is much appreciated. All our libraries together have more than 100 million downloads, if everyone could contribute a tiny amount, it would help us to make the .NET community a better place to code!

Another great free way to contribute is  **spreading the word** about the library!
 
A **HUGE THANKS** for your help.

## More Projects

- [EntityFramework Extensions](https://entityframework-extensions.net/)
- [Dapper Plus](https://dapper-plus.net/)
- [C# Eval Expression](https://eval-expression.net/)
- and much more! 
To view all our free and paid librariries visit our [website](https://zzzprojects.com/).
