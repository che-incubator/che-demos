# Devfile Demo

## Introduction
Devfile is a new format for defining a development environment, aka Che Workspace.
It's a straightforward and declarative format and `chectl` provides easy way to start using it.
`chectl` is able to generate devfile for live application. Then generated devfile can be put into
sources code repository to make it reusable on any Che installation.

## Setup
1. Create minishift/minikube VM
    - Demo is tested with minishift VM with 8GB memory allocated
2. Deploy Che Server to local cluster
    - `chectl server:start [-p minishift]`
    - After start, additional configuration:
      - `CHE_WORKSPACE_SIDECAR_IMAGE__PULL__POLICY=IfNotPresent`
    - Start custom plugin registry from `sleshchenko/che-plugin-registry:cached-typescript` and configure Che Server to use it
    *Alternatively:*
    ```bash
      # Set tested Che Server image
      export CHE_IMAGE_REPO=sleshchenko/che-server
      export CHE_IMAGE_TAG=devfile-demo

      export CHE_WORKSPACE_SIDECAR_IMAGE__PULL__POLICY=IfNotPresent

      # custom plugin registry has cached binaries for typescript plugin
      # and it saves ~1 minute on workspace start
      export PLUGIN_REGISTRY_IMAGE="sleshchenko/che-plugin-registry"
      export PLUGIN_REGISTRY_IMAGE_TAG="cached-typescript"

      ./deploy_che.sh --deploy-che-plugin-registry --project=che
    ```
3. Modify `deploy_k8s.yaml` to match VM's IP address in ingress:
    - `sed -i "s/192.168.99.100/$(minishift ip)/g" ./deploy_k8s.yaml`
4. Install tested binaries of `chectl` https://drive.google.com/drive/folders/1zz8mNfYl-cPmVUP0SJVd4tf34ePdb9ed?usp=sharing
5. Deploy NodeJS application using [deploy_k8s.yaml](deploy_k8s.yaml)
   ```bash
     oc new-project nodejs-app
     oc apply -f deploy_k8s.yaml
   ```
   And then check that application is available on http://nodejs.$(minishift ip).nip.io/
6. Run through demo once or cache all images for a smoother experience

### Note
To avoid potential issues, it may be safer to use a known working image (tested with image `sleshchenko/che-server:devfile-demo` available in dockerhub)
- Latest `7.0.0-beta-5.0` should be also working

## Script (timing ~15 minutes)

- Demonstrate NodeJS sample application
  - Demonstrate that you have NodeJS sample application that uses mongo for storing data https://github.com/sleshchenko/NodeJS-Sample-App
  - Demonstrate that you have this application deployed on Kubernetes/OpenShift with dashboard (deployments, services, ingresses, PVCs)
  - Demo that application works fine but there is a bug, it's not possible to remove employee.
    Application should be available at http://nodejs.$(minishift ip).nip.io/
- Demonstrate Devfile
  - Use `chectl devfile:generate` command to generate Devfile:
    ```bash
    chectl devfile:generate \
      --namespace='nodejs-app' \
      --selector='app.kubernetes.io/name=employee-manager' \
      --git-repo='https://github.com/sleshchenko/NodeJS-Sample-App.git' \
      --language=typescript > generated.devfile.yaml
    ```
  - Demonstrate generated [Devfile](generated.devfile.yaml)
- Customize generated Devfile to be able to start developing
  - Make kubernetes component alias simpler, remove `app.kubernetes.io/name=` and leave only `employee-manager`
  - Override NodeJS container entrypoint not to start an application from the beginning.
    The following fields should be added to `web-app` container
    ```yaml
      command: ["tail"]
      args: ["-f", "/dev/null"]
    ```
  - Configure a commands to build, run and stop an application
    Add the following section to Devfile
    ```yaml
      commands:
      - name: run
        actions:
          - type: exec
            component: employee-manager
            command: cd ${CHE_PROJECTS_ROOT}/NodeJS-Sample-App.git/EmployeeDB && node app.js
      - name: stop
        actions:
          - type: exec
            component: employee-manager
            command: pkill node
    ```
  - *Alternatively*, show diff between generated devfile and `ready-to-use.devfile.yml`, explaining differences
- Fix the bug
  - Start a workspace from modified [Devfile](ready-to-use.devfile.yaml)
    - `chectl workspace:start --devfile=ready-to-use.devfile.yaml`
  - Find and fix the bug in source code: `_` is missing before `id` in delete method
  - Run application with run task and follow Theia instructions to access your application
  - Demonstrate that the application is updated and bug is fixed
- Share Devfile
  - Add the Devfile to NodeJS application sources
  - Modify the Devfile to reference deploy_k8s.yaml and override entrypoint instead of containing all k8s objects
    Replace `referenceContent` kubernetes component with the following fields:
    ```yaml
      reference: deploy_k8s.yaml
      entrypoints:
      - containerName: web-app
      command: ["tail"]
      args: ["-f", "/dev/null"]
    ```
  - Create a workspace with factory by Github URL http://che-che.192.168.99.100.nip.io/f?url=https://github.com/sleshchenko/NodeJS-Sample-App
    Note that all changes are already committed and pushed to repository. No need to push it yourself
