#ifndef YOUR_HEADER_H
#define YOUR_HEADER_H

#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllexport) const char* generateMsgsC(const char* origin);
__declspec(dllexport) void freeMsg(const char* msg);

#ifdef __cplusplus
}
#endif

#endif // YOUR_HEADER_H
