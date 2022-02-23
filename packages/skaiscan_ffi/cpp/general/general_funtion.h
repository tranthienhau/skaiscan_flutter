#include <string>
void platform_log(const char *fmt, ...);

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


//curl reponse to dart side
struct CurlResponse{
    const char* data;
    int status;
};

//read file data to dart side convert to Uint8List
struct FileData{
    uint8_t* bytes;
    int length;
};

//curl form data use with [curl_post_form_data]
struct CurlFormData{
    std::string name;
    std::string value;
    int type;
};