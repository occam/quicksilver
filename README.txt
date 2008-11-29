How to build the Quicksilver trunk with Xcode

For those of you that like living on the bleeding edge, here are the required steps to get a working Quicksilver from trunk:

1.  Get the source from trunk as usual (git clone git://github.com/occam/quicksilver.git).
2.  Edit Configuration/Developer.xcconfig, and set QS_SOURCE_ROOT to the directory you've checked the source to.
3.  Relaunch Xcode. It seems to have issue refreshing its build settings when they are not changed from the Build Settings.

Hack away !
