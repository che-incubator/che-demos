# Devfile Demo

## Introduction
TODO

## Script (timing ~15 minutes)

- Deploy Node JS application with Mongo
  - Demonstrate content of [deploy_k8s.yaml](deploy_k8s.yaml)
  - Execute
    * `oc new-project nodejs-app`
    * `oc apply -f deploy_k8s.yaml`
  - Demo that application works fine but there is a bug, it's not possible to remove employee.
    On minishift/minikube it should be available at http://nodejs.192.168.99.100.nip.io/
- Demonstrate Devfile
  - Use `chectl devfile:generate` command to generate Devfile:
      * chectl devfile:generate --language=typescript \
                                --selector="app.kubernetes.io/name=employee-manager" \
                                --git-repo=https://github.com/sleshchenko/NodeJS-Sample-App.git
                                --namespace=nodejs-app > generated.devfile.yaml
  - Demonstrate generated [Devfile](generated.devfile.yaml)
- Customize generated Devfile to be able to start developing
  - Override nodejs container entrypoint not to start an application from the begging
  - Configure a commands to build, run and stop an application
- Fix the bug
  - Start a workspace from modified [Devfile](ready-to-use.devfile.yaml)
  - Find and fix the bug in source code: `_` is missing before `id` in delete method
  - Execute build task
  - Run application with run task and following Theia instructions to access your application
  - Demonstrate that the application is updated and bug is fixed
