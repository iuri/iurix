
# OO JS Implementation
Going further on OOJS, I still don’t see too much applicability, implementing frontend code with OOJS.

My scenario is TCL-TK and XoTCL (OO) as technologies for the backend. The web server and the framework OpenACS are written in TCL-TK, and PostgreSQL is the DB, that contains plsql functions in the database layer. 

Thus, there’s no much need for OOJS, except if I split the backend in 2. Similarly to what I’ve done already, with Wordpress/CpdeIgniter/CakePHP/Drupal/… ), having a WebService written in TCL (JSON or XML-RPC), connecting frontend and backend implemented in TCL too. 

So, all those PHP framework could be replaced by a OOJS application handled by NodeJS.

Furthemore, I found myself writing in JS a new interface to PGSQL, between NodeJS and PostgreSQL, and then OpenACS would be removed from the scenario. 

In fact, I’ve been writing a few objects in OOJS, referenced by OpenACs data models cr_items and cr_revisions.


## OBJECT's model looks like

### Object Model

#### Content Repository

The content repository is an extension of the ACS Object Model. The following diagram illustrates the relationship among the standard object types defined by the content repository (click on a box to view a description and API summary for a particular object type):

![alt Object Model](https://iurix.com/file-storage/view/Screen_Shot_2019-04-13_at_19.56.21.png)

Note that content revisions and content items inherit separately from the root of the object model. Each item may be related to one or more revisions, but they are fundamentally different types of objects.

Also important to note is the relationship between custom content types and the rest of the object model. You define new content types as subtypes of Content Revision, not of Content Item. This is because new content types are characterized by their attributes, which are stored at the revision level to make changes easy to audit. Custom content types typically do not require additional unaudited attributes or methods beyond those already provided by the Content Item type. It is thereful almost never necessary to create a custom subtype of Content Item itself.


```

public abstract	class object {
    public integer object_id = 0;
    public string name() {
	     return "Object Name:" + this.objectName;
    }
}

public abstract class content_keyword : object {
}

public abstract class content_item : object {
}

public abstract class content_revision : object {
}

public abstract class content_folder : content_item {
}

public abstract class content_template : content_item {
}

public abstract class content_symlink : content_item {
}

public abstract class content_extlink : content_item {
}

public abstract class custom_content_types : content_item {
}

```
