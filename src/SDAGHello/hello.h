#ifndef __HELLO_H__
#define __HELLO_H__


class Hello : public CBase_Hello {
	Hello_SDAG_CODE
private:
	int size;
	int p;
	int current_p;
	int neighbors;
	int n_received;
 public:

  /// Constructors ///
  Hello(int in_size, int in_phases);
  Hello(CkMigrateMessage *msg);

  /// Entry Methods ///
  //void receive(int from, int sender_phase, int direction);
  void receive_impl(int from, int sender_phase, int direction);
  void new_phase( void );
};


#endif //__HELLO_H__
