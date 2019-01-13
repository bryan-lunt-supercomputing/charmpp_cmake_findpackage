#include "hello.decl.h"

#include "hello.h"
#include "main.decl.h"


extern /* readonly */ CProxy_Main mainProxy;


Hello::Hello() {
  // Nothing to do when the Hello chare object is created.
  //   This is where member variables would be initialized
  //   just like in a C++ class constructor.
}


// Constructor needed for chare object migration (ignore for now)
// NOTE: This constructor does not need to appear in the ".ci" file
Hello::Hello(CkMigrateMessage *msg) { }


void Hello ::sayHi(int from) {

  // Have this chare object say hello to the user.
  CkPrintf("\"Hello\" from Hello chare # %d on "
           "processor %d (told by %d).\n",
           thisIndex, CkMyPe(), from);

  // Report to the Main chare object that this chare object
  //   has completed its task.
  mainProxy.done();
}


#include "hello.def.h"
