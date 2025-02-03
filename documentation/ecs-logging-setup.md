# Elastic ECS Logs Integration

## Introduction

A basic setup for logging with Elastic Common Schema (ECS) in Java, allowing you to send logs from your application to Elasticsearch. 

## Installing Elastic Logging Dependency

In the `pom.xml` file, add the following dependency to enable elastic logging:

```xml
<!-- elastic logging -->
<dependency>
    <groupId>co.elastic.logging</groupId>
    <artifactId>logback-ecs-encoder</artifactId>
    <version>1.6.0</version> <!-- Latest version from : https://mvnrepository.com/artifact/co.elastic.logging/ecs-logging-core -->
</dependency>
<!-- end of elastic logging -->
```

## Create the logging conguration file

Create the _logback-spring.xml_ file under src/main/resources/ with the following content :

```xml
<!-- Spring Pet Clinic Logback Configuration File -->
<configuration>
  <!-- Define a property for the log file path -->
  <property name="LOG_FILE" value="${LOG_FILE:-${LOG_PATH:-${LOG_TEMP:-${java.io.tmpdir:-/tmp}}}/spring.log}"/>

  <!-- Define properties explicitly for Logback using Spring Properties -->
  <springProperty name="SERVICE_NAME" source="SERVICE_NAME" defaultValue="elastic-petclinic"/>
  <springProperty name="SERVICE_VERSION" source="SERVICE_VERSION" defaultValue="1.0.0"/>
  <springProperty name="SERVICE_ENVIRONMENT" source="SERVICE_ENVIRONMENT" defaultValue="development"/>
  <springProperty name="SERVICE_NODE_NAME" source="SERVICE_NODE_NAME" defaultValue="node-1"/>
  <springProperty name="TEAM" source="TEAM" defaultValue="default-team"/>

  <!-- Include Logback default configuration files -->
  <include resource="org/springframework/boot/logging/logback/defaults.xml"/>
  <include resource="org/springframework/boot/logging/logback/console-appender.xml"/>
  <include resource="org/springframework/boot/logging/logback/file-appender.xml"/>
  <include resource="co/elastic/logging/logback/boot/ecs-console-appender.xml"/>
  <include resource="co/elastic/logging/logback/boot/ecs-file-appender.xml"/>

  <!-- Define an ECS File Appender with a unique filename -->
  <appender name="ECS_JSON_FILE" class="ch.qos.logback.core.FileAppender">
    <!-- Set the file path to include the log level and timestamp -->
    <file>${LOG_FILE}.ecs.json</file>
    <encoder class="co.elastic.logging.logback.EcsEncoder">
      <!-- Add ECS-specific fields to the logs -->
      <serviceName>${SERVICE_NAME}</serviceName>
      <serviceVersion>${SERVICE_VERSION}</serviceVersion>
      <serviceEnvironment>${SERVICE_ENVIRONMENT}</serviceEnvironment>
      <serviceNodeName>${SERVICE_NODE_NAME}</serviceNodeName>
      <includeMarkers>true</includeMarkers>
      <stackTraceAsArray>false</stackTraceAsArray>
      <!-- Add an additional fields -->
      <additionalField>
        <key>team</key>
        <value>${TEAM}</value>
      </additionalField>
    </encoder>
  </appender>

  <!-- Set the root level to INFO and include all appenders -->
  <root level="INFO">
    <!-- Do not use ECS console appender, only log files -->
    <appender-ref ref="ECS_JSON_CONSOLE"/>
    <!--
    Uncomment ECS  output to console
    <appender-ref ref="ECS_JSON_FILE"/>
    Uncomment standard output to console
    <appender-ref ref="CONSOLE"/>
    Uncomment standard output to file
    <appender-ref ref="FILE"/> 
    -->
  </root>
</configuration>
```

## Configure the overall applciation

Modify the _application.properties_ file under src/main/resources/ with the following content that you can adapt per your needs:

```bash
# database init, supports mysql too
database=h2
spring.sql.init.schema-locations=classpath*:db/${database}/schema.sql
spring.sql.init.data-locations=classpath*:db/${database}/data.sql

# Web
spring.thymeleaf.mode=HTML

# JPA
spring.jpa.hibernate.ddl-auto=none
spring.jpa.open-in-view=true

# Internationalization
spring.messages.basename=messages/messages

# Actuator
management.endpoints.web.exposure.include=*

# Logging
logging.config=classpath:logback-spring.xml
logging.file.name=petclinic-instrumented.log
logging.level.org.springframework=INFO
logging.level.org.springframework.web=INFO
logging.level.org.springframework.context.annotation=TRACE

# Maximum time static resources should be cached
spring.web.resources.cache.cachecontrol.max-age=12h

# Setting up variables
SERVICE_NAME=elastic-petclinic
SERVICE_VERSION=2.5.1
SERVICE_ENVIRONMENT=staging
SERVICE_NODE_NAME=node-2
TEAM=security-team
```

Here's a breakdown of each option in the configuration file who've been added for the purpose of this project:

**Logging**

* `logging.config=classpath:logback-spring.xml`: Specifies the configuration file for logging. In this case, it's a Logback configuration file.
* `logging.file.name=petclinic-instrumented.log`: Sets the name of the log file.
* `logging.level.org.springframework=INFO`: Sets the log level for Spring framework classes to INFO (i.e., only log messages with severity INFO or higher).
* `logging.level.org.springframework.web=INFO`: Sets the log level for Spring Web-related classes to INFO.
* `logging.level.org.springframework.context.annotation=TRACE`: Sets the log level for Spring Context and Annotation-related classes to TRACE (i.e., logs all debug information).

**Variables**

* `SERVICE_NAME=elastic-petclinic`: Sets an environment variable named `SERVICE_NAME` to the value "elastic-petclinic".
* `SERVICE_VERSION=2.5.1`: Sets an environment variable named `SERVICE_VERSION` to the value "2.5.1".
* `SERVICE_ENVIRONMENT=staging`: Sets an environment variable named `SERVICE_ENVIRONMENT` to the value "staging".
* `SERVICE_NODE_NAME=node-2`: Sets an environment variable named `SERVICE_NODE_NAME` to the value "node-2".
* `TEAM=security-team`: Sets an environment variable named `TEAM` to the value "security-team".

## Reference

* [Elastic ECS Logging](https://www.elastic.co/guide/en/ecs-logging/java/current/setup.html)