#include "hello.decl.h"

#include "hello.h"
#include "main.decl.h"

#include <cassert>


extern /* readonly */ CProxy_Main mainProxy;


Hello::Hello(int in_size, int in_phases) {
  // Nothing to do when the Hello chare object is created.
  //   This is where member variables would be initialized
  //   just like in a C++ class constructor.
  this->size = in_size;
  this->p = in_phases;
  this->current_p = 0;
  this->neighbors = 2;
  this->n_received = 0;
}


// Constructor needed for chare object migration (ignore for now)
// NOTE: This constructor does not need to appear in the ".ci" file
Hello::Hello(CkMigrateMessage *msg) { }


void Hello ::receive_impl(int from, int sender_phase, int direction) {

  // Have this chare object say hello to the user.
  CkPrintf("Element  %d (phase %d) on processor %d received from %d (p=%d) in direction %d.\n",
           thisIndex, this->current_p, CkMyPe(), from, sender_phase, direction);

  CkAssert(sender_phase == this->current_p);
  assert(sender_phase == this->current_p);

}

void Hello ::new_phase() {
  this->current_p++;
  if(this->current_p > this->p){
	  //done
	  mainProxy.done();
	  return;
  }


  this->n_received = 0;
  // Have this chare object say hello to the user.
  CkPrintf("Element  %d on processor %d starting phase %d.\n",
           thisIndex, CkMyPe(), this->current_p);

  //Signal my neighbors
  int left_neighbor = (thisIndex-1);
  if(left_neighbor < 0) left_neighbor = this->size-1;

  thisProxy[left_neighbor].receive(thisIndex, this->current_p, -1);
  thisProxy[(thisIndex+1)%(this->size)].receive(thisIndex, this->current_p, 1);

}

#include "hello.def.h"
