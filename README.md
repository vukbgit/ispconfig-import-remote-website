# ispconfig-import-remote-website
import website content from a remote ISPConfig server to a local one, currently using *scp*

The best option to migrate website hosted on an ISPConfig server is to use their [ISPConfig Migration Toolkit](https://www.ispconfig.org/add-ons/ispconfig-migration-tool/) and thus support their gret work!

*But* if you've done the website setup by yourself and you just need to mirror files from old server to new one you could use this quick-and-dirty shell script:

* login as root into the new server
* clone the repository
* edit config.sh file, it's quite straight forward and commented
* call script passing path to config file as first argument (so that you can have multipe config file if needed):
`./import.sh config.sh`
* script performs checks over variables and asks confirmation
* if you confirm, transfer is performed and file permission are set to the local user
