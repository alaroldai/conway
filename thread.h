#import <pthread.h>
#import <iostream>
#import <Foundation/Foundation.h>
class ThreadBase {
public:
	ThreadBase();

	virtual ~ThreadBase();

	void start();

	void join();

	virtual void run() = 0;

private:
	pthread_t *mThreadBasePtr;
};

static void *threadBaseDispatcher(void *arg);

class Monitor {
protected:
	pthread_mutex_t mutex;
	pthread_cond_t condition;

public:
	Monitor();
	virtual ~Monitor();

	void wait();

    BOOL timed_wait_ms(int duration);

    void notifyOne();

    void notifyAll();
};