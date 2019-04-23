# Devfile Demo

## Introduction
TODO

## Script (timing ~15 minutes)

- Deploy Node JS application with Mongo
  - Demonstrate content of [node-js-sample.yaml](node-js-sample.yaml)
  - Execute
    * `oc new-project nodejs-app`
    * `oc apply -f node-js-sample.yaml`
  - Demo that application works fine. On minishift/minikube it should be available at http://nodejs.192.168.99.100.nip.io/
- Demonstrate Devfile
  - Use `chectl devfile:generate` command to generate Devfile:
      * chectl devfile:generate --language=typescript \
            --selector="app.kubernetes.io/name=employee-manager" \
            --project='{"name":"nodejs-sample-appp", "source": "https://github.com/sleshchenko/NodeJS-Sample-App.git"}' \
            --namespace=nodejs-app > generated.devfile.yaml
  - Demonstrate generated [Devfile](generated.devfile.yaml)
- Customize generated Devfile to be able to start developing
  - Override nodejs container entrypoint not to start an application from the begging
  - Configure a commands to build,run and stop an application
- Develop an application
  - Start a workspace from modified [Devfile](ready-to-use.devfile.yaml)
  - Build and Start an application with tasks
  - Demonstrate that the application that is run in workspace is working but bug is there
  - Fix the bug
  - Restart the application with tasks
  - Demonstrate that the application is updated and bug is fixed
