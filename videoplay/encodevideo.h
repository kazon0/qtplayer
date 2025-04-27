#ifndef ENCODEVIDEO_H
#define ENCODEVIDEO_H
#include <QThread>
#include <QQueue>
#include <QDebug>

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

class encodeVideo:public QThread
{
    Q_OBJECT        //信号和槽必须要加
public:
    encodeVideo();
    //准备工作
    void initEncode();
    //写尾帧
    void writeTrailer();

private:
    AVFormatContext * formatContext;    //文件上下文环境对象
    AVCodecContext * codecContext;      //编码器上下文环境对象
    AVPacket * packet;                  //码流数据（压缩数据）
    int pktIndex;                       //码流数据序号
    QQueue<AVFrame *> YUVQueue;         //YUV格式原画数据队列
    bool flag;


    // QThread interface
protected:
    void run();

public slots:
    void reciverYUV(AVFrame * yuv);     //槽函数接收数据
    void closeFile();

};

#endif // ENCODEVIDEO_H
