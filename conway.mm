#import <SDL/SDL.h>
#import <iostream>
#import <Foundation/Foundation.h>

using std::cout;
using std::endl;

enum EventResult {
	EventResultNoChange = 0
};

class Conway {
	SDL_Surface *screen;

	SDL_Surface *frontBuffer, *backBuffer;

	BOOL done;

	public: 
	Conway() {
		screen = SDL_SetVideoMode( 640, 480, 32, SDL_SWSURFACE);
		frontBuffer =
			SDL_CreateRGBSurface(SDL_SWSURFACE,
				screen->h,
				screen->w,
				screen->format->BitsPerPixel,
				screen->format->Rmask,
				screen->format->Gmask,
				screen->format->Bmask,
				screen->format->Amask);

		backBuffer =
			SDL_CreateRGBSurface(SDL_SWSURFACE,
				screen->h,
				screen->w,
				screen->format->BitsPerPixel,
				screen->format->Rmask,
				screen->format->Gmask,
				screen->format->Bmask,
				screen->format->Amask);
	}

	int handleEvent(SDL_Event &event)
	{
		if (event.type == SDL_QUIT)
		{
			done = YES;
		}
		return 0;
	}

	int run() {
		done = NO;

		// Events

		while (!done) {
			SDL_Event event;
        	// Respond to any events that occur
        	while(SDL_PollEvent(&event)) {
        	    int eventResult = handleEvent(event);
        	}


		}

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