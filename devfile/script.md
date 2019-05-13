# Devfile Demo

## Introduction
Devfile is a new format for defining a development environment, aka Che Workspace.
It's a straightforward and declarative format and `chectl` provides easy way to start using it.
`chectl` is able to generate devfile for live application. Then generated devfile can be put into
sources code repository to make it reusable on any Che installation.

## Setup
1. Create minishift/minikube VM
    - Demo is tested with minishift VM with 8GB memory allocated
2. Deploy Che server to local cluster
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
5. Run through demo once or cache all images for a smoother experience

### Note
To avoid potential issues, it may be safer to use a known working image (tested with image `sleshchenko/che-server:devfile-demo` available in dockerhub)
- Latest `7.0.0-beta-5.0` is also working

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
    ```bash
    chectl devfile:generate \
      --namespace='nodejs-app' \
      --selector='app.kubernetes.io/name=employee-manager' \
      --git-repo='https://github.com/sleshchenko/NodeJS-Sample-App.git' \
      --language=typescript > generated.devfile.yaml
    ```
  - Demonstrate generated [Devfile](generated.devfile.yaml)
- Customize generated Devfile to be able to start developing
  - Override nodejs container entrypoint not to start an application from the beginning
  - Configure a commands to build, run and stop an application
  - *Alternatively*, show diff between generated devfile and `ready-to-use.devfile.yml`, explaining differences
- Fix the bug
  - Start a workspace from modified [Devfile](ready-to-use.devfile.yaml)
    - `chectl workspace:start --devfile=ready-to-use.devfile.yaml`
  - Find and fix the bug in source code: `_` is missing before `id` in delete method
  - Execute build task
  - Run application with run task and following Theia instructions to access your application
  - Demonstrate that the application is updated and bug is fixed
- Share Devfile
  - Add the devfile to NodeJS application sources
  - Modify the Devfile to reference deploy_k8s.yaml and override entrypoint instead of containing all k8s objects
  - Create a workspace with factory by Github URL http://che-che.192.168.99.100.nip.io/f?url=https://github.com/sleshchenko/NodeJS-Sample-App

##### TODO
- [ ] Rework Dockerfile of sample application to use CentOS image to avoid permissions issues on OpenShift
- [x] Rebuild newer Che images (Che Server, Plugin Registry)
- [ ] Write introduction
- [ ] Consider moving "Deploy NodeJS" app to set up phase to have more time on demonstrating Che instead of sample application
- [ ] Theia Next is build on each commit and it's not stable process. For demo it would be better to use some unmodifiable docker image that is referenced in built custom plugin registry
- [x] Since chectl is used from branch and there is no corresponding release, it is needed to host used binaries somewhere

##### Faced issues
- [x] Che uses not latest version of Che Theia by default. Fixed by https://github.com/eclipse/che/pull/13235
- [x] Plugin Registry was broken. Fixed by https://github.com/eclipse/che-plugin-registry/pull/134
- [ ] Unable to set up entrypoint for application container during generate Devfile phase.
It's needed to edit generated devfile to make it usable for development. Nice to improve this part.
- [ ] Permissions on OpenShift. Application works fine on image that was used initially node:12.0-alpine, but
is workspace there are issues because of anyuid.
- [ ] Wait for mongo with init container. There is an issue in workspace if application has init containers
that waits for another component, like mongo database. This topic should be investigated more. Maybe it's
good enough just to manually remove init containers is such case.
- [ ] There is no way to bound projects sources to application container. https://github.com/eclipse/che/issues/12554 should be implemented to avoid including projects PVC to application deployment
- [ ] Different arguments for deploying Che with `chectl`, auto pick up `CHE_` env vars
- [ ] Ingress vs Route
