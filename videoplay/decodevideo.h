#ifndef DECODEVIDEO_H
#define DECODEVIDEO_H

#include <QImage>
#include <QDebug>
#include <QThread>

extern "C"
{
#include "libavcodec/avcodec.h"
#include "libavdevice/avdevice.h"
#include "libavfilter/avfilter.h"
#include "libavformat/avformat.h"
#include "libavutil/avutil.h"
#include "libpostproc/postprocess.h"
#include "libswresample/swresample.h"
#include "libswscale/swscale.h"
}

class DecodeVideo:public QThread
{
    Q_OBJECT
public:
    DecodeVideo();
    //解码准备工作
    void initDecode();
    //RGB 像素数据 准备工作
    void initRGB();
    //YUV数据准备工作
    void initYUV();
    //解码 视频核心逻辑
    void Decodeing();
private:
    int video_input;//视频流序号
    int size;
    QImage frame; //保存一帧解码出来的数据
    AVFormatContext * formatContext;//视频文件上下文环境对象
    AVCodecContext * codecContext;//解码器上下文环境对象
    AVCodec * decoder; //解码器
    AVPacket * packet;  //一帧码流压缩数据
    AVFrame * pictrue; //解码出来的一帧像素数据

    AVFrame * pictureRGB; //RGB像素数据
    int imgByteRGB;
    uint8_t *bufferRGB;

    AVFrame * pictureYUV;
    int imgByteYUV;
    uint8_t * bufferYUV;
    SwsContext * SwsContextRGB;
    SwsContext * SwsContextUVY;
protected:
    //解码核心逻辑
    void run();
signals:
    void sendImage(QImage image);

};

#endif // DECODEVIDEO_H
