#include "general_funtion.h"
#include <opencv2/opencv.hpp>
#include <chrono>
#include<opencv2/imgproc.hpp>
#include<opencv2/photo.hpp>
#include<opencv2/highgui.hpp>

using namespace cv;
using namespace std;


Mat &convert_black_to_transparent(Mat &mask, Mat &result_mask) {

    Mat gray, thresh_hold;

    cvtColor(mask, gray, COLOR_BGR2GRAY);

    threshold(gray, thresh_hold, 0, 255, THRESH_BINARY);

    Mat bgra[4];
    split(mask, bgra);

    vector<Mat> mask_channels;

    mask_channels.push_back(bgra[0]);
    mask_channels.push_back(bgra[1]);
    mask_channels.push_back(bgra[2]);
    mask_channels.push_back(thresh_hold);

    gray.release();

    thresh_hold.release();

    merge(mask_channels, result_mask);

    return result_mask;
}

Mat &thresh_hold_one_acne(Mat &image, Mat &dst) {
    std::vector<std::vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
    findContours(image, contours, hierarchy, cv::RETR_CCOMP, cv::CHAIN_APPROX_NONE);

    dst = Mat::zeros(dst.size(), CV_8UC1);
    for (size_t i = 0; i < contours.size(); i++) {

        double area = contourArea(contours[i]);
        if (area >= 3) {
            Scalar color = Scalar(255);
            drawContours(dst, contours, (int) i, color, -1);
        }
    }

    return dst;
}

Mat &thresh_hold_all_acne_mat(Mat &mask, Mat &dst) {
    Mat blackheads;
    Mat whiteheads;
    Mat papules;
    Mat pustules;
//    Mat merge_acne;

    inRange(mask, Scalar(1), Scalar(1), blackheads);
    thresh_hold_one_acne(blackheads, blackheads);
    threshold(blackheads, blackheads, 1, 1, THRESH_BINARY);

    inRange(mask, Scalar(2), Scalar(2), whiteheads);
    thresh_hold_one_acne(whiteheads, whiteheads);
    threshold(whiteheads, whiteheads, 2, 2, THRESH_BINARY);

    inRange(mask, Scalar(3), Scalar(3), papules);
    thresh_hold_one_acne(papules, papules);
    threshold(papules, papules, 3, 3, THRESH_BINARY);

    inRange(mask, Scalar(4), Scalar(4), pustules);
    thresh_hold_one_acne(pustules, pustules);
    threshold(pustules, pustules, 4, 4, THRESH_BINARY);

    add(blackheads, whiteheads, dst);
    add(dst, papules, dst);
    add(dst, pustules, dst);

    return dst;
}

extern "C" {

FUNCTION_ATTRIBUTE
unsigned char *
convert_mask_to_color(uint8_t *mask_bytes, int32_t *imgLengthBytes, int width, int height) {
    cv::Mat acne_mask(height, width, CV_8UC1, mask_bytes);
    cvtColor(acne_mask, acne_mask, COLOR_GRAY2BGR);

    std::vector<uchar> buf(1);
    cv::imencode(".bmp", acne_mask, buf);
    *imgLengthBytes = static_cast<int32_t>(buf.size());

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());

    return ret;
}


FUNCTION_ATTRIBUTE
unsigned char *
merge_thresh_hold_acne(void *blackheads_ptr, void *whiteheads_ptr, void *papules_ptr,
                       void *pustules_ptr, int32_t *img_length_bytes) {
    cv::Mat *blackheads = (Mat *) blackheads_ptr;
    cv::Mat *whiteheads = (Mat *) whiteheads_ptr;
    cv::Mat *papules = (Mat *) papules_ptr;
    cv::Mat *pustules = (Mat *) pustules_ptr;

    Mat merge_acne;
    add(*blackheads, *whiteheads, merge_acne);
    add(merge_acne, *papules, merge_acne);
    add(merge_acne, *pustules, merge_acne);

    std::vector<uchar> buf;

    if (merge_acne.isContinuous()) {
        buf.assign((uchar *) merge_acne.datastart, (uchar *) merge_acne.dataend);
    } else {
        for (int i = 0; i < merge_acne.rows; ++i) {
            buf.insert(buf.end(), merge_acne.ptr<uchar>(i),
                       merge_acne.ptr<uchar>(i) + merge_acne.cols);
        }
    }

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    *img_length_bytes = buf.size();
    memcpy(ret, buf.data(), buf.size());
    return ret;
}

FUNCTION_ATTRIBUTE
unsigned char *
thresh_hold_acne_index_mask_bytes(uint8_t *mask_bytes, int32_t *img_length_bytes, int mask_width,
                                  int mask_height, int index) {
    cv::Mat mask(mask_height, mask_width, CV_8UC1, mask_bytes);
    Mat result;
    inRange(mask, Scalar(index), Scalar(index), result);
    thresh_hold_one_acne(result, result);

    std::vector<uchar> buf;


    if (result.isContinuous()) {
        buf.assign((uchar *) result.datastart, (uchar *) result.dataend);
    } else {
        for (int i = 0; i < result.rows; ++i) {
            buf.insert(buf.end(), result.ptr<uchar>(i),
                       result.ptr<uchar>(i) + result.cols);
        }
    }

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    *img_length_bytes = buf.size();
    memcpy(ret, buf.data(), buf.size());
    return ret;
}

FUNCTION_ATTRIBUTE
void *
thresh_hold_acne_index_mask_bytes_to_mat(uint8_t *mask_bytes,
                                         int mask_width,
                                         int mask_height, int index) {
    cv::Mat mask(mask_height, mask_width, CV_8UC1, mask_bytes);
    Mat result;
    inRange(mask, Scalar(index), Scalar(index), result);
    thresh_hold_one_acne(result, result);

    Mat *mat_ptr = new Mat(mask);

    return mat_ptr;
}

FUNCTION_ATTRIBUTE
unsigned char *
thresh_hold_acne_mask_bytes(uint8_t *mask_bytes, int32_t *img_length_bytes, int mask_width,
                            int mask_height) {

    cv::Mat mask(mask_height, mask_width, CV_8UC1, mask_bytes);
    Mat blackheads;
    Mat whiteheads;
    Mat papules;
    Mat pustules;
    Mat merge_acne;

    inRange(mask, Scalar(1), Scalar(1), blackheads);
    thresh_hold_one_acne(blackheads, blackheads);

    threshold(blackheads, blackheads, 1, 1, THRESH_BINARY);
    merge_acne = blackheads;

//    inRange(mask, Scalar(2), Scalar(2), whiteheads);
//    thresh_hold_one_acne(whiteheads, whiteheads);
//    threshold(whiteheads, whiteheads, 2, 2, THRESH_BINARY);
//
//    inRange(mask, Scalar(3), Scalar(3), papules);
//    thresh_hold_one_acne(papules, papules);
//    threshold(papules, papules, 3, 3, THRESH_BINARY);
//
//    inRange(mask, Scalar(4), Scalar(4), pustules);
//    thresh_hold_one_acne(pustules, pustules);
//    threshold(pustules, pustules, 4, 4, THRESH_BINARY);
//
//    add(blackheads, whiteheads, merge_acne);
//    add(merge_acne, papules, merge_acne);
//    add(merge_acne, pustules, merge_acne);

    std::vector<uchar> buf;


    if (merge_acne.isContinuous()) {
        buf.assign((uchar *) merge_acne.datastart, (uchar *) merge_acne.dataend);
    } else {
        for (int i = 0; i < merge_acne.rows; ++i) {
            buf.insert(buf.end(), merge_acne.ptr<uchar>(i),
                       merge_acne.ptr<uchar>(i) + merge_acne.cols);
        }
    }

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    *img_length_bytes = buf.size();
    memcpy(ret, buf.data(), buf.size());
    return ret;
//    uchar *arr = merge_acne.isContinuous() ? merge_acne.data : merge_acne.clone().data;
//    uint length = merge_acne.total() * merge_acne.channels();
//    *img_length_bytes = length;
//    return arr;
}

FUNCTION_ATTRIBUTE
unsigned char *
apply_acne_mask_color_v2(uint8_t *mask_bytes, uint8_t *origin_bytes, int32_t *img_length_bytes,
                         int mask_width, int mask_height,
                         int origin_width, int origin_height) {


    Mat origin_mat_bgra;
    int32_t a = *img_length_bytes;
    std::vector<unsigned char> m;

    while (a >= 0) {
        m.push_back(*(origin_bytes++));
        a--;
    }

    origin_mat_bgra = cv::imdecode(m, cv::IMREAD_UNCHANGED);

    cv::Mat acne_mask(mask_height, mask_width, CV_8UC1, mask_bytes);

    vector<MaskColorData> mask_colors;
    mask_colors.push_back(MaskColorData(1, 0, 0, 128));

    mask_colors.push_back(MaskColorData(2, 255, 255, 0));

    mask_colors.push_back(MaskColorData(3, 0, 255, 0));

    mask_colors.push_back(MaskColorData(4, 139, 0, 0));


    unsigned char r[256] = {0};
    unsigned char g[256] = {0};
    unsigned char b[256] = {0};

    for (int i = 0; i < mask_colors.size(); i++) {

        auto color_data = mask_colors[i];
        r[color_data.index] = static_cast<unsigned char>(color_data.red);
        g[color_data.index] = static_cast<unsigned char>(color_data.green);
        b[color_data.index] = static_cast<unsigned char>(color_data.blue);
    }

//    thresh_hold_all_acne_mat(acne_mask, acne_mask);

    cvtColor(acne_mask, acne_mask, COLOR_GRAY2BGR);


    Mat channels[] = {Mat(256, 1, CV_8U, b), Mat(256, 1, CV_8U, g), Mat(256, 1, CV_8U, r)};
    Mat lut; // Create a lookup table
    merge(channels, 3, lut);

    Mat mask_color;

    LUT(acne_mask, lut, mask_color);

    Mat result_mask;

    convert_black_to_transparent(mask_color, result_mask);

    resize(result_mask, result_mask, origin_mat_bgra.size(), INTER_CUBIC);

    GaussianBlur(result_mask, result_mask, Size(3, 3), 0);

    Mat result;

    addWeighted(result_mask,
                0.8, origin_mat_bgra, 1.0, 0, result);

    std::vector<uchar> buf(1);

    cv::imencode(".bmp", result, buf);

    *img_length_bytes = static_cast<int32_t>(buf.size());

    unsigned char *ret = (unsigned char *) malloc(buf.size());

    memcpy(ret, buf.data(), buf.size());

    return ret;
}


FUNCTION_ATTRIBUTE
unsigned char *
apply_acne_mask_color_jpg(uint8_t *mask_bytes, uint8_t *origin_bytes, int32_t *imgLengthBytes,
                          int mask_width, int mask_height,
                          int origin_width, int origin_height) {

    Mat origin_mat_bgra;
    int32_t a = *imgLengthBytes;
    std::vector<unsigned char> m;

    while (a >= 0) {
        m.push_back(*(origin_bytes++));
        a--;
    }

    origin_mat_bgra = cv::imdecode(m, cv::IMREAD_UNCHANGED);

    cv::Mat acne_mask(mask_height, mask_width, CV_8UC1, mask_bytes);

    vector<MaskColorData> mask_colors;

    mask_colors.push_back(MaskColorData(1, 0, 0, 128));

    mask_colors.push_back(MaskColorData(2, 255, 255, 0));

    mask_colors.push_back(MaskColorData(3, 0, 255, 0));

    mask_colors.push_back(MaskColorData(4, 139, 0, 0));

    unsigned char r[256] = {0};
    unsigned char g[256] = {0};
    unsigned char b[256] = {0};

    for (int i = 0; i < mask_colors.size(); i++) {

        auto color_data = mask_colors[i];
        r[color_data.index] = static_cast<unsigned char>(color_data.red);
        g[color_data.index] = static_cast<unsigned char>(color_data.green);
        b[color_data.index] = static_cast<unsigned char>(color_data.blue);
    }


    cvtColor(acne_mask, acne_mask, COLOR_GRAY2BGR);

    Mat channels[] = {Mat(256, 1, CV_8U, b), Mat(256, 1, CV_8U, g), Mat(256, 1, CV_8U, r)};
    Mat lut; // Create a lookup table
    merge(channels, 3, lut);

    Mat mask_color;

    LUT(acne_mask, lut, mask_color);

    Mat result_mask;

    convert_black_to_transparent(mask_color, result_mask);

    resize(result_mask, result_mask, origin_mat_bgra.size(), INTER_CUBIC);

    GaussianBlur(result_mask, result_mask, Size(3, 3), 0);

    Mat result;

    addWeighted(result_mask,
                0.8, origin_mat_bgra, 1.0, 0, result);

//    resize(origin_resize, origin_resize, origin_mat_bgra.size(), INTER_LINEAR);

    std::vector<uchar> buf(1);

    cv::imencode(".jpg", result, buf);

    *imgLengthBytes = static_cast<int32_t>(buf.size());

    unsigned char *ret = (unsigned char *) malloc(buf.size());

    memcpy(ret, buf.data(), buf.size());

    return ret;
}


FUNCTION_ATTRIBUTE
unsigned char *
apply_acne_mask_color(uint8_t *mask_bytes, void *origin_ptr, int32_t *imgLengthBytes, int width,
                      int height) {
    cv::Mat *origin_mat = (Mat *) origin_ptr;

    cv::Mat acne_mask(height, width, CV_8UC1, mask_bytes);

    vector<MaskColorData> mask_colors;

    mask_colors.push_back(MaskColorData(1, 249, 224, 150));

    mask_colors.push_back(MaskColorData(2, 244, 182, 145));

    mask_colors.push_back(MaskColorData(3, 216, 138, 135));

    mask_colors.push_back(MaskColorData(4, 166, 161, 235));

    unsigned char r[256] = {0};
    unsigned char g[256] = {0};
    unsigned char b[256] = {0};

    for (int i = 0; i < mask_colors.size(); i++) {

        auto color_data = mask_colors[i];
        r[color_data.index] = static_cast<unsigned char>(color_data.red);
        g[color_data.index] = static_cast<unsigned char>(color_data.green);
        b[color_data.index] = static_cast<unsigned char>(color_data.blue);
    }

    cvtColor(acne_mask, acne_mask, COLOR_GRAY2BGR);

    Mat origin_resize;

    resize(*origin_mat, origin_resize, acne_mask.size(), INTER_LINEAR);


    Mat channels[] = {Mat(256, 1, CV_8U, b), Mat(256, 1, CV_8U, g), Mat(256, 1, CV_8U, r)};
    Mat lut; // Create a lookup table
    merge(channels, 3, lut);

    Mat mask_color;
    LUT(acne_mask, lut, mask_color);
    Mat result_mask;
    convert_black_to_transparent(acne_mask, result_mask);

    GaussianBlur(result_mask, result_mask, Size(11, 11), 0);

    addWeighted(result_mask,
                1, origin_resize, 1.0, 0, origin_resize);


    std::vector<uchar> buf(1);
    cv::imencode(".bmp", origin_resize, buf);
    *imgLengthBytes = static_cast<int32_t>(buf.size());

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());
    result_mask.release();
    lut.release();
    mask_color.release();
    origin_resize.release();
    acne_mask.release();

    return ret;
}


}
