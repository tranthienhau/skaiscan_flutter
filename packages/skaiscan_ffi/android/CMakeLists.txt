cmake_minimum_required(VERSION 3.4.1)

include_directories(../cpp/general)

set(CPP_ROOT src/main/cpp)

set(SRC_FILES
        ../cpp/general/general_funtion.h
        ../cpp/general/general_funtion.cpp
        ../cpp/native_opencv.cpp
        ../cpp/native_skaiscan.cpp
        )
add_library(native-lib SHARED ${SRC_FILES})
#set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv-mobile-4.5.4-android/sdk/native/jni)
#find_package(OpenCV REQUIRED)
#include_directories(${CMAKE_CURRENT_SOURCE_DIR}/opencv-mobile-4.5.4-android/sdk/native/jni/include)

# target_link_libraries(your_jni_target ${OpenCV_LIBS})

#add_library(libopencv_core STATIC IMPORTED)
#set_target_properties(libopencv_core PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/static_libs/${ANDROID_ABI}/libopencv_core.a)
#
#add_library(libopencv_features2d STATIC IMPORTED)
#set_target_properties(libopencv_features2d PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/static_libs/${ANDROID_ABI}/libopencv_features2d.a)
#
#add_library(libopencv_highgui STATIC IMPORTED)
#set_target_properties(libopencv_highgui PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/static_libs/${ANDROID_ABI}/libopencv_highgui.a)
#
#add_library(libopencv_imgproc STATIC IMPORTED)
#set_target_properties(libopencv_imgproc PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/static_libs/${ANDROID_ABI}/libopencv_imgproc.a)
#
#add_library(libopencv_photo STATIC IMPORTED)
#set_target_properties(libopencv_photo PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/static_libs/${ANDROID_ABI}/libopencv_photo.a)

#add_library(libopencv_video STATIC IMPORTED)
#set_target_properties(libopencv_video PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/static_libs/${ANDROID_ABI}/libopencv_video.a)
#

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/include)
add_library(lib_opencv SHARED IMPORTED)
set_target_properties(lib_opencv PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/src/main/opencv2/libs/${ANDROID_ABI}/libopencv_java4.so)

target_link_libraries(native-lib ${log-lib} ${android-lib})
# Link libraries
target_link_libraries(native-lib
                      z
                      #${OpenCV_LIBS}
#                      libopencv_core
#                      libopencv_features2d
#                      libopencv_highgui
#                      libopencv_imgproc
#                      libopencv_photo
                      #libopencv_video
                      lib_opencv
                      android
                      log)
