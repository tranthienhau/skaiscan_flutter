#include "general_funtion.h"
#include <opencv2/opencv.hpp>
#include <chrono>
#include<opencv2/imgproc.hpp>
#include<opencv2/photo.hpp>
#include<opencv2/highgui.hpp>

using namespace cv;
using namespace std;

struct MaskColorData {
    int index;

    int red;

    int green;

    int blue;

    MaskColorData(int index, int red, int green, int blue) {
        this->index = index;
        this->red = red;
        this->green = green;
        this->blue = blue;
    };
};

Mat &convert_black_to_transperant(Mat &mask, Mat &result_mask) {

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
apply_acne_mask_color_v2(uint8_t *mask_bytes, uint8_t *origin_bytes, int32_t *imgLengthBytes,
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

//    cv::Mat origin_mat_bgra(origin_height, origin_width, CV_8UC4, origin_bytes);

//    Mat origin_mat;
//
//    cvtColor(origin_mat_bgra, origin_mat, COLOR_BGRA2BGR);

    cv::Mat acne_mask(mask_height, mask_width, CV_8UC1, mask_bytes);

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

    resize(origin_mat_bgra, origin_resize, acne_mask.size(), INTER_LINEAR);


    Mat channels[] = {Mat(256, 1, CV_8U, b), Mat(256, 1, CV_8U, g), Mat(256, 1, CV_8U, r)};
    Mat lut; // Create a lookup table
    merge(channels, 3, lut);

    Mat mask_color;
    LUT(acne_mask, lut, mask_color);
    Mat result_mask;
    convert_black_to_transperant(acne_mask, result_mask);

    GaussianBlur(result_mask, result_mask, Size(11, 11), 0);

    addWeighted(result_mask,
                1, origin_resize, 1.0, 0, origin_resize);

    resize(origin_resize, origin_resize, origin_mat_bgra.size(), INTER_LINEAR);

    std::vector<uchar> buf(1);
    cv::imencode(".bmp", origin_resize, buf);
    *imgLengthBytes = static_cast<int32_t>(buf.size());

    unsigned char *ret = (unsigned char *) malloc(buf.size());
    memcpy(ret, buf.data(), buf.size());
//
//    result_mask.release();
//    lut.release();
//    mask_color.release();
//    origin_resize.release();
//    acne_mask.release();

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
    convert_black_to_transperant(acne_mask, result_mask);

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
