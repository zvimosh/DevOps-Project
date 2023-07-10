FROM tomcat:9.0 
ADD ./*.war /usr/local/tomcat/webapps/
ENTRYPOINT ["catalina.sh", "run"]

