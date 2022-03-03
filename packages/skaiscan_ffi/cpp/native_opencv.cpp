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

#include <opencv2/imgproc/types_c.h>

#endif


using namespace cv;
using namespace std;


long long int get_now() {
    return chrono::duration_cast<std::chrono::milliseconds>(
            chrono::system_clock::now().time_since_epoch()
    ).count();
}

struct NativeColor {
    int red;

    int green;

    int blue;
};

struct NativeRectangle {
    int x;

    int y;

    int width;

    int height;
};

//struct MaskColorData {
//   int index;
//
//   int red;
//
//   int green;
//
//   int blue;
//
//  MaskColorData(int index,int red, int green, int blue){
//      this->index = index;
//      this->red = red;
//      this->green = green;
//      this->blue = blue;
//  };
//};
int clamp(int lower, int higher, int val) {
    if (val < lower)
        return 0;
    else if (val > higher)
        return 255;
    else
        return val;
}

int getRotatedImageByteIndex(int x, int y, int rotatedImageWidth) {
    return rotatedImageWidth * (y + 1) - (x + 1);
}



void rotateMat(Mat &matImage, int rotation) {
    if (rotation == 90) {
        transpose(matImage, matImage);
        flip(matImage, matImage, 1); //transpose+flip(1)=CW
    } else if (rotation == 270) {
        transpose(matImage, matImage);
        flip(matImage, matImage, 0); //transpose+flip(0)=CCW
    } else if (rotation == 180) {
        flip(matImage, matImage, -1);    //flip(-1)=180
    }
}

uint32_t *
convert_yuv_to_rbga_bytes(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow,
                          int bytesPerPixel, int width, int height) {
    int hexFF = 255;
    int x, y, uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;

    uint32_t *image = (uint32_t *) malloc(sizeof(uint32_t) * (width * height));

    for (x = 0; x < width; x++) {
        for (y = 0; y < height; y++) {

            uvIndex = bytesPerPixel * ((int) floor(x / 2)) + bytesPerRow * ((int) floor(y / 2));
            index = y * width + x;

            yp = plane0[index];
            up = plane1[uvIndex];
            vp = plane2[uvIndex];
            rt = round(yp + vp * 1436 / 1024 - 179);
            gt = round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91);
            bt = round(yp + up * 1814 / 1024 - 227);
            r = clamp(0, 255, rt);
            g = clamp(0, 255, gt);
            b = clamp(0, 255, bt);
            image[getRotatedImageByteIndex(y, x, height)] =
                    (hexFF << 24) | (b << 16) | (g << 8) | r;
//                image[getRotatedImageByteIndex(y, x, height)] = (hexFF << 24) | (r << 16) | (g << 8) | b;
        }
    }

    return image;
}



// Avoiding name mangling
extern "C" {

FUNCTION_ATTRIBUTE
const char *version() {
    return CV_VERSION;
}

FUNCTION_ATTRIBUTE
void *create_mat_pointer() {
    cv::Mat *src = new Mat();

    return src;
}

FUNCTION_ATTRIBUTE
void free_mat_ptr(void *src_ptr) {
    cv::Mat *src = (Mat *) src_ptr;
    if (src == nullptr || src->data == nullptr) {
        return;
    }

    src->release();
    delete src;
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
unsigned char *convert_mat_to_bytes(void *src_ptr, int32_t *imgLengthBytes) {
    cv::Mat *src = (Mat *) src_ptr;
    *imgLengthBytes = 0;
    if (src == nullptr || src->data == nullptr) {
        return nullptr;
    }

    std::vector<uchar> buf(1);
    cv::imencode(".bmp", *src, buf);
    *imgLengthBytes = buf.size();

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());
    return ret;
}

FUNCTION_ATTRIBUTE
void *create_mat_pointer_from_path(char *inputImagePath) {

    Mat image = imread(inputImagePath, IMREAD_COLOR);

    Mat *matPointer = new Mat(image);

    return matPointer;
}


//    Mat* global_bgra_mat_ptr = nullptr;
FUNCTION_ATTRIBUTE
Mat *create_mat_from_bgra_bytes(unsigned char *bytes, int width, int height) {
    cv::Mat src(height, width, CV_8UC4, bytes);

    Mat *mat_ptr = new Mat();
    *mat_ptr = src.clone();

    src.release();

    return mat_ptr;
}

FUNCTION_ATTRIBUTE
Mat *convert_camera_image_to_mat(unsigned char *bytes, bool is_yuv, int rotation, int width,
                                 int height) {

    Mat frame;
    if (is_yuv) {
        Mat myyuv(height + height / 2, width, CV_8UC1, bytes);
        cvtColor(myyuv, frame, COLOR_YUV2RGBA_NV21);
    } else {
        frame = Mat(height, width, CV_8UC4, bytes);
    }

    rotateMat(frame, rotation);
    Mat *mat_ptr = new Mat();
    *mat_ptr = frame.clone();

    frame.release();

    return mat_ptr;
}


//FUNCTION_ATTRIBUTE

//Mat *global_mat_ptr = nullptr;

//FUNCTION_ATTRIBUTE
//Mat *convert_camera_image_to_mat_v2(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, bool is_yuv,
//                                    int bytesPerRow, int bytesPerPixel, int width, int height) {
//
//    Mat frame;
//
//    uint32_t *rgba_bytes = nullptr;
//
//    if (is_yuv) {
//        rgba_bytes = convert_yuv_to_rbga_bytes(plane0, plane1, plane2, bytesPerRow, bytesPerPixel,
//                                               width, height);
//        cv::Mat rgba_mat((width), (height), CV_8UC4, rgba_bytes);
//        cvtColor(rgba_mat, frame, COLOR_RGBA2BGRA);
//        flip(frame, frame, 0);
//
//    } else {
//        frame = Mat(height, width, CV_8UC4, plane0);
//    }
//
//    Mat *mat_ptr = new Mat();
//
//    *mat_ptr = frame.clone();
//
//    if (is_yuv) {
//        delete[] rgba_bytes;
//    }
//
//    frame.release();
//
//    return mat_ptr;
//}

FUNCTION_ATTRIBUTE
unsigned char *convert_camera_image_to_mat_v3(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2,
                                              int32_t *imgLengthBytes, bool is_yuv, int bytesPerRow,
                                              int bytesPerPixel, int width, int height) {

    Mat frame;

    uint32_t *rgba_bytes = nullptr;

    if (is_yuv) {
        rgba_bytes = convert_yuv_to_rbga_bytes(plane0, plane1, plane2, bytesPerRow, bytesPerPixel,
                                               width, height);
        cv::Mat rgba_mat((width), (height), CV_8UC4, rgba_bytes);
        cvtColor(rgba_mat, frame, COLOR_RGBA2BGRA);
        flip(frame, frame, 0);
    } else {
        frame = Mat(height, width, CV_8UC4, plane0);
    }

    std::vector<uchar> buf(1);
    cv::imencode(".bmp", frame, buf);
    *imgLengthBytes = buf.size();

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());

    if (rgba_bytes != nullptr) {
        delete[] rgba_bytes;
    }

    frame.release();

    return ret;
}


FUNCTION_ATTRIBUTE
unsigned char *convert_camera_image_to_bytes_jpg(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2,
                                              int32_t *imgLengthBytes, bool is_yuv, int bytesPerRow,
                                              int bytesPerPixel, int width, int height) {

    Mat frame;

    uint32_t *rgba_bytes = nullptr;

    if (is_yuv) {
        rgba_bytes = convert_yuv_to_rbga_bytes(plane0, plane1, plane2, bytesPerRow, bytesPerPixel,
                                               width, height);
        cv::Mat rgba_mat((width), (height), CV_8UC4, rgba_bytes);
        cvtColor(rgba_mat, frame, COLOR_RGBA2BGRA);
        flip(frame, frame, 0);
    } else {
        frame = Mat(height, width, CV_8UC4, plane0);
    }

    std::vector<uchar> buf(1);
    cv::imencode(".jpg", frame, buf);
    *imgLengthBytes = buf.size();

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());

    if (rgba_bytes != nullptr) {
        delete[] rgba_bytes;
    }

    frame.release();

    return ret;
}


FUNCTION_ATTRIBUTE
void *create_mat_from_yuv(uint8_t *plane0, uint8_t *plane1, uint8_t *plane2, int bytesPerRow,
                          int bytesPerPixel, int width, int height) {
    int hexFF = 255;
    int x, y, uvIndex, index;
    int yp, up, vp;
    int r, g, b;
    int rt, gt, bt;

    uint32_t *image = (uint32_t *) malloc(sizeof(uint32_t) * (width * height));

    for (x = 0; x < width; x++) {
        for (y = 0; y < height; y++) {

            uvIndex = bytesPerPixel * ((int) floor(x / 2)) + bytesPerRow * ((int) floor(y / 2));
            index = y * width + x;

            yp = plane0[index];
            up = plane1[uvIndex];
            vp = plane2[uvIndex];
            rt = static_cast<int>(round(yp + vp * 1436 / 1024 - 179));
            gt = static_cast<int>(round(yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91));
            bt = static_cast<int>(round(yp + up * 1814 / 1024 - 227));
            r = clamp(0, 255, rt);
            g = clamp(0, 255, gt);
            b = clamp(0, 255, bt);
//                image[getRotatedImageByteIndex(y, x, height)] = (hexFF << 24) | (b << 16) | (g << 8) | r;
            image[getRotatedImageByteIndex(y, x, height)] =
                    static_cast<uint32_t>((hexFF << 24) | (r << 16) | (g << 8) | b);
        }
    }

    cv::Mat src((width), (height), CV_8UC4, image);


    platform_log("create_mat_from_yuv: len:%d  width:%d  height:%d", src.step[0] * src.rows,
                 src.cols, src.rows);

    Mat *mat_ptr = new Mat();
    *mat_ptr = src.clone();

    src.release();
    delete[] image;

    return mat_ptr;
}

FUNCTION_ATTRIBUTE
void *draw_rectangle(void *src_ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    cv::Mat *src = (Mat *) src_ptr;
    if (src == nullptr || src->data == nullptr)
        return nullptr;

    Rect rect(x, y, width, height);

    cv::rectangle(*src, rect, cv::Scalar(0, 255, 0));

    return src;
}


FUNCTION_ATTRIBUTE
void *crop_mat(void *src_ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    cv::Mat *src = (Mat *) src_ptr;

    cv::Mat *cropped_image = new Mat();

    *cropped_image = (*src)(Range(y, y + height), Range(x, x + width));

    return cropped_image;
}


FUNCTION_ATTRIBUTE
void *crop_image_bytes(unsigned char *bytes, int32_t *imgLengthBytes, int32_t x, int32_t y, int32_t width,
                 int32_t height) {
    cv::Mat src;
    int32_t a = *imgLengthBytes;
    std::vector<unsigned char> m;

    while (a >= 0) {
        m.push_back(*(bytes++));
        a--;
    }

    src = cv::imdecode(m, cv::IMREAD_UNCHANGED);

    cv::Mat cropped_image;

    cropped_image = src(Range(y, y + height), Range(x, x + width));

    std::vector<uchar> buf(1);
    cv::imencode(".bmp", cropped_image, buf);
    *imgLengthBytes = buf.size();

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());

    return ret;
}


FUNCTION_ATTRIBUTE
void *crop_image_jpg_bytes(unsigned char *bytes, int32_t *imgLengthBytes, int32_t x, int32_t y, int32_t width,
                       int32_t height) {
    cv::Mat src;
    int32_t a = *imgLengthBytes;
    std::vector<unsigned char> m;

    while (a >= 0) {
        m.push_back(*(bytes++));
        a--;
    }

    src = cv::imdecode(m, cv::IMREAD_UNCHANGED);

    cv::Mat cropped_image;

    cropped_image = src(Range(y, y + height), Range(x, x + width));

    std::vector<uchar> buf(1);
    cv::imencode(".jpg", cropped_image, buf);
    *imgLengthBytes = buf.size();

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());

    return ret;
}


//
//void convert_black_to_transperant(Mat &mask) {
//
//    Mat gray, thresh_hold;
//
//    cvtColor(mask, gray, COLOR_BGR2GRAY);
//
//    threshold(gray, thresh_hold, 0, 255, THRESH_BINARY);
//
//    Mat bgra[4];
//    split(mask, bgra);
//
//    vector<Mat> mask_channels;
//
//    mask_channels.push_back(bgra[0]);
//    mask_channels.push_back(bgra[1]);
//    mask_channels.push_back(bgra[2]);
//    mask_channels.push_back(thresh_hold);
//
//    merge(mask_channels, mask);
//
//    gray.release();
//
//    thresh_hold.release();
//}
//

}
