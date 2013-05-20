#import "conway.h"

#import <SDL/SDL.h>
#import <iostream>
#import <vector>
#import <boost/thread/thread.hpp>
#import <Foundation/Foundation.h>

static int WIDTH = 480;
static int HEIGHT = 640;
static int NUMTHREADS = 4;
static int TARGETFPS = 30;

using std::cout;
using std::endl;
using std::vector;

static UInt32 ALIVE;
static UInt32 DEAD;

enum EventResult {
	EventResultNoChange = 0
};

class Conway {

	CGSize resolution;

	SDL_Surface *screen;
	SDL_Surface *buffer;

	vector<UInt32 *>cells;

	BOOL done;
	UInt32 targetFrameRate;

	public: 
	Conway() {

	}

	BOOL setup() {

		done = NO;

		resolution = (CGSize) {
			HEIGHT,
			WIDTH
		};

		targetFrameRate = 1000 / TARGETFPS;

		screen = SDL_SetVideoMode((int)resolution.width, (int)resolution.height, 32, SDL_SWSURFACE | SDL_DOUBLEBUF);
		buffer = SDL_CreateRGBSurface(SDL_SWSURFACE,
				screen->w,
				screen->h,
				screen->format->BitsPerPixel,
				screen->format->Rmask,
				screen->format->Gmask,
				screen->format->Bmask,
				screen->format->Amask);


		ALIVE = SDL_MapRGB(screen->format, 255, 255, 255);
		DEAD = SDL_MapRGB(screen->format, 0, 0, 0);

		cells = vector<UInt32 *>(resolution.height);
		for (int i = 0; i < resolution.height; i++) {
			cells[i] = ((UInt32 *)buffer->pixels + i * (int)resolution.width);
		}

		for (int y = 0; y < resolution.height; y++) {
			for (int x = 0; x < resolution.width; x++) {
				CGPoint cell = CGPointMake(x, y);
				if (!(rand() % 2)) {
					createCell(cell);
				} else {
					killCell(cell);
				}
			}
		}

		render();

		return YES;
	}

	BOOL tearDown() {
		return YES;
	}

	int handleEvent(SDL_Event &event)
	{
		if (event.type == SDL_QUIT)
		{
			done = YES;
		}
		return 0;
	}

	int handleEvents() {
		SDL_Event event;
		// Respond to any events that occur
       	while(SDL_PollEvent(&event)) {
       	    int eventResult = handleEvent(event);
       	}
       	return YES;
	}

	BOOL isCellLive(CGPoint cell) {
		if (cell.x >= 0 && cell.x < resolution.width && cell.y >= 0 && cell.y < resolution.height) {
			UInt32 valueAtCell = *((UInt32 *)screen->pixels + ((int)cell.y * (int)resolution.width) + (int)cell.x);
			if (valueAtCell == ALIVE) {
				return YES;
			} else if (valueAtCell == DEAD) {
				return NO;
			} else {
				cout << "Error: Bad pixel " << valueAtCell << endl;
				exit(1);
			}
		}
		return NO;
	}

	void checkCell(CGPoint cell, int *countref) {
		if (isCellLive(cell)) {
			(*countref) ++;
		}
	}

	void killCell(CGPoint cell) {
		cells[(int)cell.y][(int)cell.x] = DEAD;
	}

	void createCell(CGPoint cell) {
		cells[(int)cell.y][(int)cell.x] = ALIVE;
	}

	int updateWithBounds(CGRect bounds) {
    	for(int y = bounds.origin.y; y < bounds.origin.y + bounds.size.height; y++) 
    	{
    	    for(int x = bounds.origin.x; x < bounds.origin.x + bounds.size.width; x++) 
    	    {
    	    	CGPoint cell = CGPointMake(x, y);
    	    	int neighbours = 0;
    	    	BOOL up, down, left, right;
    	    	up = y > 0;
    	    	down = y < resolution.height - 1;
    	    	left = x > 0;
    	    	right = x < resolution.width - 1;

    	    	if (up) {
    	    		checkCell(CGPointMake(x, y - 1), &neighbours);
    	    		if (left) {
    	    			checkCell(CGPointMake(x - 1, y - 1), &neighbours);
    	    		}
    	    		if (right) {
    	    			checkCell(CGPointMake(x + 1, y - 1), &neighbours);
    	    		}
    	    	}
    	    	if (down) {
    	    		checkCell(CGPointMake(x, y + 1), &neighbours);
    	    		if (left) {
    	    			checkCell(CGPointMake(x - 1, y + 1), &neighbours);
    	    		}
    	    		if (right) {
    	    			checkCell(CGPointMake(x + 1, y + 1), &neighbours);
    	    		}
    	    	}
    	    	if (left) {
    	    		checkCell(CGPointMake(x - 1, y), &neighbours);
    	    	}
    	    	if (right) {
    	    		checkCell(CGPointMake(x + 1, y), &neighbours);
    	    	}

    	    	if (isCellLive(cell)) {
    	    		if (neighbours < 2) {
    	    			// cout << "Killing live cell (neighbours == " << neighbours << ")" << endl;
    	    			killCell(cell);
    	    		} else if (neighbours == 3 || neighbours == 2) {
    	    			// cout << "Keeping cell live (neighbours == " << neighbours << ")" << endl;
    	    			createCell(cell);
    	    		} else {
    	    			// cout << "Killing live cell (neighbours == " << neighbours << ")" << endl;
    	    			killCell(cell);
    	    		}
    	    	} else {
    	    		if (neighbours == 3) {
    	    			// cout << "Creating live cell (neighbours == " << neighbours << ")" << endl;

						createCell(cell);
	        		} else {
      	    			// cout << "Keeping cell dead (neighbours == " << neighbours << ")" << endl;
	        			killCell(cell);
	        		}
    	    	}

    	    }
    	}
    	return YES;
	}

	int staticUpdate() {

		vector<boost::thread *> threads(NUMTHREADS);
		for (int i = 0; i < NUMTHREADS; i++) {
			CGRect bounds = CGRectMake(0, i * (resolution.height / NUMTHREADS), resolution.width, resolution.height / NUMTHREADS);
			boost::thread *t = new boost::thread(boost::bind(&Conway::updateWithBounds, this, bounds));
			threads[i] = t;
		}
		for (int i = 0; i < NUMTHREADS; i++) {
			threads[i]->join();
			delete threads[i];
		}
	}

	BOOL copySurface(SDL_Surface* srcSurface, SDL_Surface* destSurface) {
 	   if(destSurface == NULL || srcSurface == NULL) {
 	       return false;
 	   }
 	 	
 	   SDL_BlitSurface(srcSurface, NULL, destSurface, NULL);
 	
    	return true;
	}

	int render() {
		copySurface(buffer, screen);
		int rc = SDL_Flip(screen);
		if (rc == 0) {
			return YES;
		} else {
			cout << "Couldn't flip screen-> Error " << rc << endl;
			throw std::runtime_error("Couldn't flip screen");
		}
	}

	int run() {
		setup();
		int frames = 0;
		while (!done) {

			UInt32 frame_start = SDL_GetTicks();

			/* Handle events */
			handleEvents();

        	/* Static updates */
        	staticUpdate();

        	/* Render */
       		render();


        	UInt32 frame_end = SDL_GetTicks();
        	if (frame_end - frame_start < targetFrameRate) {
        		SDL_Delay(targetFrameRate - (frame_end - frame_start));
        	}
		}
		tearDown();
		return 0;
	}
};

int main(int argc, char *argv[])
{
	SDL_Init(SDL_INIT_EVERYTHING);
	atexit(SDL_Quit);

	Conway app;
	return app.run();
}