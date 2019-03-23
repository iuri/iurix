# iurix
iurix is community based system, with multiple applications and tools for CMS, messaging, management, projects, ecommerce, blog and etc

The goal is to build software to facilitate poeples communication, team's engagement and involvement in the field of software development, engineering, architecture designing and whatever else is possible in the real world using software and hardware technologies and the human brain, its rationals and senses.


## Description

Designing a data system or service is a lot of tricky and questions arise during its implementation. 

### How do you ensure that the data remains correct and complete, even when things go wrong internally? 

There's not unique solution. A few aspects must be covered and complied to support reliability, scalability and maintenability. 

The question bellow are intented to cover all these aspects.

### How do you provide consistently good performance to clients, even when parts of your system are degraded? 

Assuring scallability, vertically and horizontally. 

#### Vertical Architecture
The design bellow, shows a vertical architecture of the message system. It describe how a client request is processed and stored and responded. 

![alt Vertical Architecture](https://www.iurix.com/resources/images/vert-arch.png)
Figure 1. One possible vertical architecture for a data system that combines several components.


The content-item module guaratees that content (i.e. messages) are reliable, scalable and maintenable.


#### Horizontal Architecture
For example, it's possible to scale the message system installed in a clustered environment where the servers can supply the absence of one of the nodes. A proxy balances the traffic to the apllication. NGINX covers this task beautifully.   

The images bellow describe a horizontal archciteture of the system.

Applications Overview
![alt Horizontal Architecture ] (https://drive.google.com/file/d/1nY_clTzs_15D0NRTncnVlgaAOJYInmi8/view?usp=sharing

![alt Horizontal Architecture 1](https://www.iurix.com/resources/images/horz-arch-2.png)


Objects Overview
![alt Horizontal Architecture 2](https://www.iurix.com/resources/images/horz-arch.png)





#### How do you scale to handle an increase in load?

Vertically and horizontally. As per description above



### What does a good API for the service look like? 

Read api-doc of content-item and acs-message
https://iurix.com/api-doc/




### Applying cache in the application, webserver and proxy levels
Applying cache in the proxy level is a matter of setting up NGINX 

By default, NGINX respects the Cache-Control headers from origin servers. It does not cache responses with Cache-Control set to Private , No-Cache , or No-Store or with Set-Cookie in the response header. NGINX only caches GET and HEAD client requests. ... NGINX does not cache responses if proxy_buffering is set to off .

To enable cache no NGINX only two directives are needed to enable basic caching: proxy_cache_path and proxy_cache. The proxy_cache_path directive sets the path and configuration of the cache, and the proxy_cache directive activates it. See the example bellow. 

More information to set up parameters can be found at official  NGINX documentation https://www.nginx.com/blog/nginx-caching-guide/

```

proxy_cache_path /path/to/cache levels=1:2 keys_zone=my_cache:10m max_size=10g 
                 inactive=60m use_temp_path=off;

server {
    # ...
    location / {
        proxy_cache my_cache;
        proxy_pass http://my_upstream;
    }
}


```

Furthermore, in the application level, utilizing cache can be implemented by writing a set of functions capable of persist data as described in the example. 

It shows 2 functions: one public and other private, acs_user::get_by_username and acs_user::get_by_username_not_cached respectively. They return user_id from authority and username. Returns the empty string if no user found. 

```
ad_proc -public acs_user::get_by_username {
    {-authority_id ""}
    {-username:required}
} {
    Returns user_id from authority and username. Returns the empty string if no user found.

    @param authority_id The authority. Defaults to local authority.

    @param username The username of the user you're trying to find.

    @return user_id of the user, or the empty string if no user found.
}  {
    # Default to local authority                                                                                                                                                                            
    if { $authority_id eq "" } {
        set authority_id [auth::authority::local]
    }

    set user_id [util_memoize [list acs_user::get_by_username_not_cached -authority_id $authority_id -username $username]]
    if {$user_id eq ""} {
        util_memoize_flush [list acs_user::get_by_username_not_cached -authority_id $authority_id -username $username]
    }
    return $user_id
}

ad_proc -private acs_user::get_by_username_not_cached {
    {-authority_id:required}
    {-username:required}
} {
    Returns user_id from authority and username. Returns the empty string if no user found.

    @param authority_id The authority. Defaults to local authority.

    @param username The username of the user you're trying to find.

    @return user_id of the user, or the empty string if no user found.
}  {
    return [db_string user_id_from_username {} -default {}]
}

    
```



In the private function, there's another function called  util_memoize_flush. Basically util_memoize_flush script is the main part for caching. If the script is executed before, returns the value, which it returned last time, unless it was more than max_age seconds ago.

Otherwise, evaluate script and cache and return the result.


```
  if {$max_age ne ""} {
            set max_age "-expires $max_age"
        }
        ns_cache_eval {*}$max_age  -- util_memoize $script {*}$script

```


The function ns_cache_eval is implemeted within util_memoize_flush. It is the point of connection between the webserver and application levels, as following in the example. In this case, a time 5 seconds into the future is constructed once and passed to both cache calls. The second call will use the remainder of the time once the first completes.

 
 
```

set timeout [ns_time incr [ns_time get] 5]
if {[catch {
    set user [ns_cache_eval -timeout $timeout -- users $userid {
        db_query {
            select name, email
            from users
            where userid = :userid
        }
    }]
    set ad [ns_cache_eval -timeout $timeout -expires 120 -- ads $userid {
        db_query {
            select advert from
            personalized_adverts
            where userid = :userid
        }
    }]
} errmsg]} {
    ns_returnunavailable "Sorry, our web server is too busy."
}
ns_return 200 text/html [example_personalized_page $user $ad]
```

## Built With

* [OpenACS](http://openacs.org/) - The web framework used
* [Naviserver](https://maven.apache.org/) - Dependency Management
* [PostgreSQL](https://sourceforge.net/projects/naviserver/) - Dependency Management - Database Server
* [NGINX](https://www.nginx.com) - Dependency Management - Proxy Server
* [Postfix](http://www.postfix.org) - Used to generate RSS Feeds


## Contributing

Please read [CONTRIBUTING.md](https://github.com/iuri/iurix/blob/master/CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.


## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/iuri/iurix). 


```
Give an example
```

## Installation

### Operating System
  Install a Unix-like operation system. Debian Server is the one selected by the author 

### Install packages
http://project-open.com/en/install-debian-stretch


## Authors

* **Iuri Sampaio** - *Initial work* - [IURIX](https://github.com/iuri/iurix)


## References 
https://github.com/donnemartin/system-design-primer
https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageBus.html
https://www.makeareadme.com/#what-is-it
http://www.project-open.com/en/install-debian
https://github.com/gustafn/install-ns
https://stackoverflow.com/questions/14494747/add-images-to-readme-md-on-github






