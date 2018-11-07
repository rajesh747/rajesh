oc login -u user1 -p r3dh4t1!
oc new-project test-nodejs
oc new-app https://github.com/sclorg/nodejs-ex -l name=test-nodejs-app
