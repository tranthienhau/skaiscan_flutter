#include <opencv2/opencv.hpp>
#include <chrono>
#include<opencv2/imgproc.hpp>
#include<opencv2/photo.hpp>
#include<opencv2/highgui.hpp>
#include "general_funtion.h"
#include <opencv2/imgproc/imgproc.hpp>
#include <iostream>
#include <string>
#include <cstdint>
#include <cstring>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32)
#define IS_WIN32
#endif

#ifdef __ANDROID__

#include <android/log.h>
#include <opencv2/imgproc/types_c.h>

#endif

#ifdef IS_WIN32
#include <windows.h>
#endif

#if defined(__GNUC__)
// Attributes to prevent 'unused' function from being removed and to make it visible
#define FUNCTION_ATTRIBUTE __attribute__((visibility("default"))) __attribute__((used))
#elif defined(_MSC_VER)
// Marking a function for export
#define FUNCTION_ATTRIBUTE __declspec(dllexport)
#endif

using namespace cv;
using namespace std;


// Avoiding name mangling
extern "C" {

}
