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


long long int get_now() {
    return chrono::duration_cast<std::chrono::milliseconds>(
            chrono::system_clock::now().time_since_epoch()
    ).count();
}

// Avoiding name mangling
extern "C" {

    FUNCTION_ATTRIBUTE
    const char *version() {
        return CV_VERSION;
    }


    FUNCTION_ATTRIBUTE
    void *create_mat_pointer_from_bytes(unsigned char *bytes,
                                       int32_t *imgLengthBytes) {
        cv::Mat *src = new Mat();
        int32_t a = *imgLengthBytes;
        std::vector<unsigned char> m;

        while (a >= 0) {
            m.push_back(*(bytes++));
            a--;
        }
        *src = cv::imdecode(m, cv::IMREAD_UNCHANGED);
        if (src->data == nullptr)
            return nullptr;

        platform_log("create_mat_pointer_from_bytes: len before:%d  len after:%d  width:%d  height:%d",
                     *imgLengthBytes, src->step[0] * src->rows,
                     src->cols, src->rows);

        *imgLengthBytes = src->step[0] * src->rows;

        return src;
    }


    FUNCTION_ATTRIBUTE
    unsigned char * convert_mat_to_bytes(void *imgMat) {
         cv::Mat *src = (Mat *) imgMat;
          if (src == nullptr || src->data == nullptr)
              return nullptr;

        std::vector<uchar> buf(1);
        cv::imencode(".bmp", *src, buf);
//        *imgLengthBytes = buf.size();

        unsigned char *ret = (unsigned char *)malloc(buf.size());
        memcpy(ret, buf.data(), buf.size());
        return ret;
    }

    FUNCTION_ATTRIBUTE
    void *create_mat_pointer_from_path(char *inputImagePath) {

        Mat image = imread(inputImagePath, IMREAD_COLOR);
        Mat *matPointer = new Mat(image);

        return matPointer;
    }

    FUNCTION_ATTRIBUTE
    void* draw_rectangle(void *imgMat,  int32_t x, int32_t y, int32_t width, int32_t height) {
        cv::Mat *src = (Mat *) imgMat;
        if (src == nullptr || src->data == nullptr)
            return nullptr;

        Rect rect(x, y, width, height);

        cv::rectangle(*src, rect, cv::Scalar(0, 255, 0));

//        std::vector<uchar> buf(1);

//        cv::imencode(".bmp", src, buf);
//
//        *imgLengthBytes = buf.size();
//
//        unsigned char *ret = (unsigned char *)malloc(buf.size());
//
//        memcpy(ret, buf.data(), buf.size());

        return src;
    }



}
