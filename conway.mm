#import <SDL/SDL.h>
#import <iostream>
#import <Foundation/Foundation.h>

using std::cout;
using std::endl;

enum EventResult {
	EventResultNoChange = 0
};

class Conway {

	CGSize resolution;

	SDL_Surface *screen;

	SDL_Surface *frontBuffer, *backBuffer;
	BOOL done;
	BOOL screenIsFrontBuffer;
	UInt32 targetFrameRate;

	public: 
	Conway() {
		// done = NO;
	}

	BOOL setup() {

		done = NO;

		resolution = (CGSize) {
			320,
			240
		};

		targetFrameRate = 1000 / 10;

		screen = SDL_SetVideoMode(resolution.width, resolution.height, 32, SDL_SWSURFACE | SDL_DOUBLEBUF);
		frontBuffer =
			SDL_CreateRGBSurface(SDL_SWSURFACE,
				screen->w,
				screen->h,
				screen->format->BitsPerPixel,
				screen->format->Rmask,
				screen->format->Gmask,
				screen->format->Bmask,
				screen->format->Amask);

		backBuffer =
			SDL_CreateRGBSurface(SDL_SWSURFACE,
				screen->w,
				screen->h,
				screen->format->BitsPerPixel,
				screen->format->Rmask,
				screen->format->Gmask,
				screen->format->Bmask,
				screen->format->Amask);

		if (!screen || !frontBuffer || !backBuffer) {
			cout << "Couldn't create surface. Bailing." << endl;
			return NO;
		}

		screenIsFrontBuffer= NO;

		for (int y = 0; y < backBuffer->h; y++) {
			for (int x = 0; x < backBuffer->w; x++) {
				if (rand() % 2) {
					createCell(*backBuffer, x, y);
				} else {
					killCell(*backBuffer, x, y);
				}
			}
		}
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

	BOOL isPixelLive(SDL_Surface &surface, int x, int y) {
		if (x >= 0 && x < surface.w && y >= 0 && y < surface.h) {
			UInt32 live = *((UInt32 *)surface.pixels + (y * surface.w) + x);
			if (live == SDL_MapRGB(surface.format, 255, 255, 255)) {
				return YES;
			} else if (live == SDL_MapRGB(surface.format, 0, 0, 0)) {
				return NO;
			} else {
				cout << "Error: Bad pixel " << live << endl;
				exit(1);
			}
		}
		return NO;
	}

	void checkPixel(SDL_Surface &surface, int x, int y, int *countref)
	{
		if (isPixelLive(surface, x, y)) {
			(*countref) ++;
		}
	}

	void killCell(SDL_Surface &surface, int x, int y) {
		*((UInt32 *)surface.pixels + (y * surface.w) + x) = SDL_MapRGB(surface.format, 0, 0, 0);
	}

	void createCell(SDL_Surface &surface, int x, int y) {
		*((UInt32 *)surface.pixels + (y * surface.w) + x) = SDL_MapRGB(surface.format, 255, 255, 255);
	}

	BOOL copySurface(SDL_Surface* srcSurface, SDL_Surface* destSurface) {
 	   if(destSurface == NULL || srcSurface == NULL) {
 	       return false;
 	   }
 	 	
 	   SDL_BlitSurface(srcSurface, NULL, destSurface, NULL);
 	
    	return true;
	}

	int staticUpdate() {
		SDL_Surface *nextBuffer = screenIsFrontBuffer ? backBuffer : frontBuffer;
		SDL_Surface *currentBuffer = screenIsFrontBuffer ? frontBuffer : backBuffer;

    	for(int y = 0; y < currentBuffer->h; y++ ) 
    	{
    	    for(int x = 0; x < currentBuffer->w; x++ ) 
    	    {
    	    	int neighbours = 0;
    	    	BOOL up, down, left, right;
    	    	up = y > 0;
    	    	down = y < currentBuffer->h - 1;
    	    	left = x > 0;
    	    	right = x < currentBuffer->w - 1;

    	    	if (up) {
    	    		checkPixel(*currentBuffer, x, y - 1, &neighbours);
    	    		if (left) {
    	    			checkPixel(*currentBuffer, x - 1, y - 1, &neighbours);
    	    		}
    	    		if (right) {
    	    			checkPixel(*currentBuffer, x + 1, y - 1, &neighbours);
    	    		}
    	    	}
    	    	if (down) {
    	    		checkPixel(*currentBuffer, x, y + 1, &neighbours);
    	    		if (left) {
    	    			checkPixel(*currentBuffer, x - 1, y + 1, &neighbours);
    	    		}
    	    		if (right) {
    	    			checkPixel(*currentBuffer, x + 1, y + 1, &neighbours);
    	    		}
    	    	}
    	    	if (left) {
    	    		checkPixel(*currentBuffer, x - 1, y, &neighbours);
    	    	}
    	    	if (right) {
    	    		checkPixel(*currentBuffer, x + 1, y, &neighbours);
    	    	}

    	    	if (isPixelLive(*currentBuffer, x, y)) {
    	    		if (neighbours < 2) {
    	    			killCell(*nextBuffer, x, y);
    	    		} else if (neighbours == 3 || neighbours == 2) {
    	    			createCell(*nextBuffer, x, y);
    	    		} else {
    	    			killCell(*nextBuffer, x, y);
    	    		}
    	    	} else {
    	    		if (neighbours == 3) {
						createCell(*nextBuffer, x, y);
	        		} else {
	        			killCell(*nextBuffer, x, y);
	        		}
    	    	}

    	    }
    	}

    	return YES;
	}

	int render() {
		SDL_Surface *nextBuffer = screenIsFrontBuffer ? backBuffer : frontBuffer;
		copySurface(nextBuffer, screen);
		screenIsFrontBuffer = !screenIsFrontBuffer;
		SDL_Flip(screen);
		return YES;
	}

	int run() {
		setup();
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