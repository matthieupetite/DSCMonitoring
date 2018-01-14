# DCS Monitoring #

This tools give the abalility for sysadmin to monitor the status of DSC configuration applied on servers deployed with the Microsoft DSC Pull Server.

The status is displayed 

1. On a website 
2. The an api exposed by the website to enable SNMP check

## The Web Site ##

| Website Main View |  Website Detailed View |
--------------------|-------------------------
| ![Global View](matthieupetite.github.com/DSCMonitoring/doc/WebSiteScreenshot.png) | ![Detailed view](matthieu.github.com/DSCMonitoring/doc/WebSiteScreenshot1.png)

## The API ##

If your website is deployed on your local IIS Server you will have access to the following url:

1. http://localhost/api : which will answer a json array with the status of all server
2. http://localhost/api/<servername>: wich will answer
   1. HTTP 200 result if the last application of the DSC Configuration is a success, 
   2. HTTP 500 result if the las application of the DSC Configuration is a failure
   3. HTTP 404 if the server is not found on the database

# Getting Started #

## Setup the pull server ##
First of all you must have configured the DSC Pull server
on a dedicated server in your infrastructure.
The steps to perform that setup are well describe on the [Microsoft Documentation Website](https://docs.microsoft.com/en-US/powershell/dsc/pullserver "Setting up a DSC Pull Server")

## Use SQL Server Database with your pull server ##

The DSC Pull Server use as a default database a [ESENT Database](https://en.wikipedia.org/wiki/Extensible_Storage_Engine). To use the website you must configure the pull server to use a classical SQL Server Database

The configuration ca be done by following the [flowing tutorial](https://blogs.technet.microsoft.com/fieldcoding/2017/05/11/using-sql-server-2016-for-a-dsc-pull-server/) and you will have some usefull details [here](https://leandrowpblog.wordpress.com/2016/10/26/using-sql-server-db-for-dsc/)

In order to create your database your server please use the script contained in the repo [here](matthieupetite.github.com/DSCMonitoring/doc/PullServerDatabaseScript.sql)

Check that the SQL Authentication is available on your instance and that your Instance is listening on all ip address.

## Prepare the IIS server ##

The website is an ASP.Net Core V2 website. Please install the windows server hosting on your server. The installation package can be found [here](https://www.microsoft.com/net/download/windows)

On the IIS server, open the management console by using the inetmgr command and then create a new website. Check that the application pool type associate to that brand new website is "Unamanged"


## Deploy the web site ##

Check out the source code of the web site and build it. Change the connexion string to target your database server. To do that simply edit the appsettings.json file located a the root of the website.

replace the "Database IP", "Database User" and the "Database Password" with your settings
```json
{
  "Logging": {
    "IncludeScopes": false,
    "LogLevel": {
      "Default": "Warning"
    }
  },
  "Database": {
    "ConnectionString": "Data Source=<DATABASE IP>;Database=DSC;Integrated Security=False;User ID=<DatabaseUser>;Password=<DatabasePassword>;Connect Timeout=30;Encrypt=False;TrustServerCertificate=True;ApplicationIntent=ReadWrite;MultiSubnetFailover=False;"
  }
}
```





