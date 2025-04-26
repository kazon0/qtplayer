#include "widget.h"
#include <QApplication>
#include <QDebug>
#include "decodevideo.h"
#include "testthread.h"
#include "mainwidget.h"

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


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
//    Widget w;
//    w.show();
//    qDebug()<<"version="<<avcodec_version();
//      DecodeVideo * decode = new DecodeVideo();
//      decode->start();
      //decode->initDecode();
//    decode->Decodeing();
//    TestThread * tt = new TestThread();
    //线程的启动 不是调用tt->run() run函数为子类重写 是受保护权限类外不能使用
    //整个线程的是run内容
//    tt->start();
//    int x=0;
//    while(1){
//        qDebug()<<"main函数主线程"<<x;
//        x++;
//        QThread::sleep(1);
//    }
    MainWidget w;
    w.show();
    return a.exec();
}
