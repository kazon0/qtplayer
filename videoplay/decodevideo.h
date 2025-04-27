#ifndef DECODEVIDEO_H
#define DECODEVIDEO_H

#include <QImage>
#include <QDebug>
#include <QString>
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

//解码类
class DecodeVideo : public QThread
{
    Q_OBJECT

public:
    DecodeVideo();
    ~DecodeVideo();

    void initDecode();  //解码准备工作  初始化
    void initRGB();     //RGB像素数据 准备工作
    void initYUV();     //YUV数据 准备工作


private:
    QImage frame;   //保存一帧解码出来的画面数据
    AVFormatContext * formatContext;    //视频上下文环境对象     等于文件指针
    AVCodecContext * codeContext;       //解码器上下文环境对象
    AVCodec * decoder;  //解码器
    AVPacket * packet;  //一帧码流（压缩）数据
    AVFrame * picture;  //解码出来的一帧像素数据

    int video_input;    //视频流编号
    int size;   //一个帧画面的像素大小
    //RGB像素数据
    AVFrame * pictureRGB;   //RGB像素数据
    int imgByteRGB;
    uint8_t * bufferRGB;    //缓冲
    SwsContext * SwsContextRGB;
    //YUV像素数据
    AVFrame * pictureYUV;
    int imgByteYUV;
    uint8_t * bufferYUV;
    SwsContext * SwsContextYUV;


    // QThread interface
protected:
    //解码 视频核心逻辑
    void run();

signals:
    void sendImage(QImage img); //RGB给窗口显示信号
    void sendYUV(AVFrame * yuv);//YUV给窗口信号
    void sendClose();
};

#endif // DECODEVIDEO_H
