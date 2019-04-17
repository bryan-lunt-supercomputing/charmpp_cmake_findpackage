#include "hello.decl.h"

/* readonly */ CProxy_Main mainProxy;
/* readonly */ CProxy_Hello helloProxy;

class Main : public CBase_Main {
  public:
    Main(CkArgMsg* m) {
      // 2 chares per PE
      int n = 2 * CkNumPes();
      helloProxy = CProxy_Hello::ckNew(n);
      helloProxy.migrate();
    }

    void done() {
      CkExit();
    }
};

class Hello : public CBase_Hello {
  int pe;

  public:
    Hello() {
      usesAtSync = true;
      pe = CkMyPe();
      CkPrintf("Hello, I'm chare %d on PE %d\n", thisIndex, pe);
    }

    Hello(CkMigrateMessage* m) { }

    void pup(PUP::er &p) {
      p|pe;
    }

    void migrate() {
      // Informs the runtime system that the chare is ready to migrate
      AtSync();
    }

    void ResumeFromSync() {
      // This print can go to the migration constructor
      CkPrintf("I'm chare %d, I moved to PE %d from PE %d\n", thisIndex, CkMyPe(), pe);

      CkCallback cb(CkReductionTarget(Main, done), mainProxy);
      contribute(cb);
    }
};

#include "hello.def.h"
