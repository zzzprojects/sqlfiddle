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

## Useful links

- [Website](http://sqlfiddle.com/)
- [Documentation](http://sqlfiddle.com/about.html)
- You can also consult SQL Fiddle questions on 
[Stack Overflow](https://stackoverflow.com/questions/tagged/sqlfiddle)

## Contribute

The best way to contribute is by **spreading the word** about the library:

 - Blog it
 - Comment it
 - Star it
 - Share it
 
A **HUGE THANKS** for your help.

## More Projects

- Projects:
   - [EntityFramework Extensions](https://entityframework-extensions.net/)
   - [Dapper Plus](https://dapper-plus.net/)
   - [C# Eval Expression](https://eval-expression.net/)
- Learn Websites
   - [Learn EF Core](https://www.learnentityframeworkcore.com/)
   - [Learn Dapper](https://www.learndapper.com/)
- Online Tools:
   - [.NET Fiddle](https://dotnetfiddle.net/)
   - [SQL Fiddle](https://sqlfiddle.com/)
   - [ZZZ Code AI](https://zzzcode.ai/)
- and much more!

To view all our free and paid projects, visit our website [ZZZ Projects](https://zzzprojects.com/).
