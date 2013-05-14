#import <pthread.h>
#import <iostream>
#import <stdexcept>
#import <sys/time.h>

#import "thread.h"
static void *threadBaseDispatcher(void *arg);

	ThreadBase::ThreadBase() : mThreadBasePtr(NULL) {

	}

	ThreadBase::~ThreadBase() {

	}

	void ThreadBase::start() {
		if (mThreadBasePtr == NULL) {
			mThreadBasePtr = new pthread_t;
			int rc = pthread_create(mThreadBasePtr, NULL, threadBaseDispatcher, this);
			if (rc != 0) {
				throw std::runtime_error("ThreadBase pthread_create failed");
			}
		} else {
			throw std::runtime_error("Multiple ThreadBase start");
		}
	}

	void ThreadBase::join() {
		if (mThreadBasePtr) {
			int rc = pthread_join(*mThreadBasePtr, NULL);
			if (rc != 0) {
				throw std::runtime_error("threadbase pthread_join failed");
			}
			delete mThreadBasePtr;
			mThreadBasePtr = NULL;
		}
	}

static void *threadBaseDispatcher(void *arg) {
	ThreadBase *thread(static_cast<ThreadBase *>(arg));
	thread->run();
	return NULL;
}


	Monitor::Monitor() {
		if (pthread_mutex_init(&mutex, NULL) != 0) {
			throw std::runtime_error("couldn't initialize monitor mutex");
		}
		if (pthread_cond_init(&condition, NULL) != 0) {
			throw std::runtime_error("couldn't initialize monitor condition");
		}
	}

	Monitor::~Monitor() {

	}

	void Monitor::wait() {
		pthread_cond_wait(&condition, &mutex);
	}

	#define NSEC_IN_MSEC 1000000
    #define NSEC_IN_SEC 1000000000
    #define MSEC_IN_SEC 1000

    BOOL Monitor::timed_wait_ms(int duration) {
    	struct timeval now;
    	gettimeofday(&now, NULL);
    	struct timespec delay;
    	delay.tv_sec = now.tv_sec + duration / MSEC_IN_SEC;
    	delay.tv_nsec = now.tv_usec*1000 + (duration % MSEC_IN_SEC) * NSEC_IN_MSEC;
    	if (delay.tv_nsec >= NSEC_IN_SEC) {
    		delay.tv_nsec -= NSEC_IN_SEC;
    		delay.tv_sec++;
    	}
    	int rc = pthread_cond_timedwait(&condition, &mutex, &delay);
    	return rc == 0;
    }

    void Monitor::notifyOne() {
    	pthread_cond_signal(&condition);
    }

    void Monitor::notifyAll() {
    	pthread_cond_broadcast(&condition);
    }
