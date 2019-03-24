# Contributuing with IURIX
## SQL Upgrade on IURIX

To apply SQL updates to the system, one must follow the steps bellow.

### 1. All the SQL must be written within 
<package-name>/sql/postgresql/upgrade/upgrade-X.XXd-X.XXd.sql
  
### 2. New release must be present within the package's XML file .info . 
Go to /packages/<pkg-name>/<pkg-name>.info.

### Amending source files
![alt Amend package's file](https://www.iurix.com/resources/images/amending-sourcefiles.png)


### 3. Go to APM package manager, 
i.e. /acs-admin/apm, and start the updgrading wizzard, in the administration section. See images bellow.

### 4. Start the wizzard
![alt Start Wizzard ](https://iurix.com/resources/images/start-wizzard.png)

### 5. Select the link to upgrade
![alt Select the link to upgrade](https://iurix.com/resources/images/select-upgrade.png)

### 6. Select the package, which one needs to be upgraded
![alt Select the package](https://iurix.com/resources/images/select-package.png)

### 7. Mark the checkbox to run SQL scripts 
![alt ](https://iurix.com/resources/images/select-SQL-script.png)

### 8. Click on "restart the system"
![alt Mark the checkbox](https://iurix.com/resources/images/restarting-system.png )

### 9. Click on "return to admin"
![alt return to admin](https://iurix.com/resources/images/return-admin.png )


## References
https://openacs.org/doc/upgrade-openacs-files
