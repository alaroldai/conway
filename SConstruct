
env=Environment()
env.Replace(CC="gcc -g", CXX="g++ -g")
env.Replace(LINK="g++ -g")

env.Program(['conway.mm', 'SDLMain.m'], LIBS=['libboost_system-mt', 'libboost_thread-mt'], FRAMEWORKS=['SDL', 'Foundation', 'Cocoa'], LIBPATH=['/usr/local/lib'])