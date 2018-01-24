@che
Feature: Che add-on
  Che addon starts Eclipse Che
  
  Scenario: User enables the che add-on
    Given executing "minishift addons install --defaults" succeeds 
    And executing "minishift addons enable anyuid" succeeds
    When file from "https://raw.githubusercontent.com/l0rd/minishift-addons/6866413f44ab265c7fa8e52e49203f17ac180454/add-ons/che/rb/che-admin-rb.json" is downloaded into location "download/che/rb"
    And file from "https://raw.githubusercontent.com/l0rd/minishift-addons/6866413f44ab265c7fa8e52e49203f17ac180454/add-ons/che/templates/che-single-user.yml" is downloaded into location "download/che/templates"
    And file from "https://raw.githubusercontent.com/l0rd/minishift-addons/6866413f44ab265c7fa8e52e49203f17ac180454/add-ons/che/che.addon" is downloaded into location "download/che"
    And executing "minishift addons install ../../out/integration-test/download/che" succeeds
    And executing "minishift addons enable che" succeeds
    Then executing "minishift addons list" succeeds
    And stdout should contain "che"
  
  Scenario: User starts Minishift
    Given Minishift has state "Does Not Exist"
    When executing "minishift start --memory 4GB" succeeds
    Then Minishift should have state "Running"
    And stdout should contain "che"
    Then executing "minishift addons apply --addon-env CHE_DOCKER_IMAGE=eclipse/che-server:nightly che" succeeds
    And stdout should contain "che"
  
  Scenario Outline: User starts workspace, imports projects, checks run commands
    Given Minishift has state "Running"
    When we try to get the che api endpoint
    Then che api endpoint should not be empty
    When starting a workspace with stack "<stack>" succeeds
    Then workspace should have state "RUNNING"
    When importing the sample project "<sample>" succeeds
    Then workspace should have 1 project
    When user runs command on sample "<sample>"
    Then exit code should be 0
    When user stops workspace
    Then workspace should have state "STOPPED"
    When workspace is removed
    Then workspace removal should be successful
    
    Examples:
    | stack                 | sample                                                                   |
    | .NET CentOS           | https://github.com/che-samples/dotnet-web-simple.git                     |
    | CentOS nodejs         | https://github.com/che-samples/web-nodejs-sample.git                     |
    | CentOS WildFly Swarm  | https://github.com/wildfly-swarm-openshiftio-boosters/wfswarm-rest-http  |
    | Eclipse Vert.x        | https://github.com/openshiftio-vertx-boosters/vertx-http-booster         |
    | Java CentOS           | https://github.com/che-samples/console-java-simple.git                   |
    | Spring Boot           | https://github.com/snowdrop/spring-boot-http-booster                     |
  
  Scenario: User deletes Minishift
     When executing "minishift delete --force" succeeds
     Then Minishift should have state "Does Not Exist"