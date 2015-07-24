Objective C (and C++) wrapper for some functionalities of https://github.com/robotology/yarp.

Repository structure:

- *apps*: container for full applications. Currently only a test application is present.
- *cmake*: contains cmake utilities (iOS.cmake toolchain file used to generate an Xcode project for iOS)
- *extern*: added only to define the repository structure. Files here should not be committed to the repository a part from particular reasons.
- *libs*: Objective C/C++ libraries

###yarp_iOS library
Currently the following stuff are implemented:

- Read a bottle from a yarp buffered port (`yarp::os::BufferedPort<yarp::os::Bottle>`)
- Read a RBG Image from a yarp port.

###Install

####Prerequisites: YARP

- Clone the YARP repository
- `mkdir build && cd build`
- Create the project. You have to options: GNU Makefiles or Xcode project (why should you use Makefiles anyway!?!)

To create an Xcode project: 
```bash 
cmake .. -GXcode -DCMAKE_TOOLCHAIN_FILE=path/to/toolchain/iOS.cmake -DCREATE_LIB_MATH:BOOL=NO -DSKIP_ACE:BOOL=YES -DCREATE_SHARED_LIBRARY:BOOL=NO -DCREATE_YARPDATADUMPER:BOOL=NO -DCREATE_YARPMANAGER_CONSOLE:BOOL=NO -DYARP_COMPILE_EXECUTABLES:BOOL=NO
````

The generated projects is completely generic: it allows you to seemlessy change between simulator and device (or..I hope). Just remember to automatically update the project settings once you open the project (hoping for better support from CMake)

If you want instead to use GNU Makefiles: 
```bash
cmake .. -DCMAKE_TOOLCHAIN_FILE=path/to/toolchain/iOS.cmake -DIOS_PLATFORM=SIMULATOR64 | SIMULATOR | OS -DCREATE_LIB_MATH:BOOL=NO -DSKIP_ACE:BOOL=YES -DCREATE_SHARED_LIBRARY:BOOL=NO -DCREATE_YARPDATADUMPER:BOOL=NO -DCREATE_YARPMANAGER_CONSOLE:BOOL=NO -DYARP_COMPILE_EXECUTABLES:BOOL=NO
``` 
You have to explicitly define the target architecture (OS, SIMULATOR or SIMULATOR64

- Optional: install the libraries (change before the CMAKE_INSTALL_PREFIX variable please!!)

####libYarp_iOS

Now you can open the workspace or simply build the Objective-C/C++ library in this repository. One thing currently left open is how to properly link the yarp libraries. If you installed the yarp libraries you can simply link them by adding the include directory and lib directory to the header and library search path and manually link the libraries (-lYARP_os, etc..)

An alternative is to install anyway yarp, so to explicitly specify the headers location in the `yarp_iOS` project, and add the YARP.xcproject project in the workspace, or as a dependency, and specify the libraries in the Build Phase->Link Binaries with Libraries. It will automatically build the right version of the library depending of the iOS project (Debug/Release, Simulator, Device)
