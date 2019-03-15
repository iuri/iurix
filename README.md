# iurix
iurix website is a message system written to facilitate people's understanding in the field of software engineering, designing, architecture and development.


## Description

Designing a data system or service is a lot of tricky and questions arise during its implementation. 

### How do you ensure that the data remains correct and complete, even when things go wrong internally? 

There's not unique solution. A few aspects must be covered and complied to support reliability, scalability and maintenability. 

The question bellow are intented to cover all these aspects.

### How do you provide consistently good performance to clients, even when parts of your system are degraded? 

Assuring scallability, vertically and horizontally. 

The design bellow, shows a vertical architecture of the message system. It describe how a client request is processed and stored and responded. 

< add image1 >
Figure 1. One possible vertical architecture for a data system that combines several components.


The content-item module guaratees that content (i.e. messages) are reliable, scalable and maintenable.


The image bellow describes a horizontal archciteture of the system.

<add image2>


For example, it's possible to scale the message system installed in a clustered environment where the servers can supply the absence of one of the nodes. A proxy balances the traffic to the apllication. NGINX covers this task beautifully.   




#### How do you scale to handle an increase in load?

Vertically and horizontally. As per description above



### What does a good API for the service look like? 

Read api-doc of content-item







```
Give an example
```


## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)





## Installation

### Operating System
  Install a Unix-like operation system. Debian Server is the one selected by the author 

### Install packages
http://project-open.com/en/install-debian-stretch


## References 
https://github.com/donnemartin/system-design-primer
https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageBus.html
https://www.makeareadme.com/#what-is-it
http://www.project-open.com/en/install-debian
https://github.com/gustafn/install-ns






