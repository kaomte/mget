PROJECT(mpkg C)
FIND_PROGRAM(MGET_LOCATION NAMES mget mget.rb
	PATHS
	/usr/local/bin
	/usr/bin/
	/bin/
)
CONFIGURE_FILE( ${CMAKE_SOURCE_DIR}/src/config.h.cmake ${CMAKE_SOURCE_DIR}/src/config.h)
ADD_EXECUTABLE(mpkg main.c)

INSTALL(TARGETS mpkg
	RUNTIME DESTINATION bin)
