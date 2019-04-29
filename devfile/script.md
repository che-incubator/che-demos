# Devfile Demo

## Setup
1. Create minishift/minikube VM
    - Demo is tested with minishift VM with 8GB memory allocated
2. Deploy Che server to local cluster
    - `chectl server:start [-p minishift]`
    - After start, additional configuration:
      - `CHE_WORKSPACE_DEVFILE_DEFAULT__EDITOR=org.eclipse.che.editor.theia:next`
        - This will need to be modified if https://github.com/eclipse/che/pull/13204 is applied to image used in demo
      - `CHE_WORKSPACE_SIDECAR_IMAGE__PULL__POLICY=IfNotPresent`
    - Start custom plugin registry from sleshchenko/che-plugin-registry:cached-typescript and configure Che Server to use it
    *Alternatively:*
    ```bash
      # Set tested Che Server image
      export CHE_IMAGE_REPO=amisevsk/che-server
      export CHE_IMAGE_TAG=dockercon

      export CHE_WORKSPACE_DEVFILE_DEFAULT__EDITOR=org.eclipse.che.editor.theia:next
      export CHE_WORKSPACE_SIDECAR_IMAGE__PULL__POLICY=IfNotPresent

      # custom plugin registry has cached binaries for typescript plugin
      # and it saves ~1 minute on workspace start
      export PLUGIN_REGISTRY_IMAGE="sleshchenko/che-plugin-registry"
      export PLUGIN_REGISTRY_IMAGE_TAG="cached-typescript"

      ./deploy_che.sh --deploy-che-plugin-registry --project=che
    ```
3. Modify `deploy_k8s.yaml` to match VM's IP address in ingress:
    - `sed -i "s/192.168.99.100/$(minishift ip)/g" ./deploy_k8s.yaml`
4. Run through demo once or cache all images for a smoother experience

### Note
To avoid potential issues, it may be safer to use a known working image (tested with image `amisevsk/che-server:dockercon` available in dockerhub)
- `7.0.0-beta-3.0` has issues parsing the generated devfile
- Current `beta-4.0` snapshot is working

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
    ```bash
    chectl devfile:generate \
      --namespace='nodejs-app' \
      --selector='app.kubernetes.io/name=employee-manager' \
      --git-repo='https://github.com/sleshchenko/NodeJS-Sample-App.git' \
      --language=typescript > generated.devfile.yaml
    ```
  - Demonstrate generated [Devfile](generated.devfile.yaml)
- Customize generated Devfile to be able to start developing
  - Override nodejs container entrypoint not to start an application from the begging
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
  - Create a workspace with factory by Github URL http://che-che.192.168.99.100.nip.io/f?url=https://github.com/sleshchenko/NodeJS-Sample-App
