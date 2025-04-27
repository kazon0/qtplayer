#include "decodevideo.h"

DecodeVideo::DecodeVideo():QThread ()
{
    //1.注册组件 有且只有一次
    av_register_all();

    this->initDecode();
}

DecodeVideo::~DecodeVideo()
{

}

//准备工作
void DecodeVideo::initDecode()
{
    //2.打开视频文件
    int res = 0;   //判断找到文件标识
    this->formatContext = avformat_alloc_context(); //初始化指针 =malloc开辟空间
    res = avformat_open_input(&(this->formatContext),"../video/Warcraft3_End.avi",nullptr,nullptr);
    if(res != 0)
    {
        qDebug()<<"avformat_open_input failed";
        return;
    }else{
        qDebug()<<"avformat_open_input success";
    }
    //3.获取视频文件信息
    res = avformat_find_stream_info(this->formatContext,nullptr);
    if(res < 0)
    {
        qDebug()<<"avformat_find_stream_info failed";
        return;
    }else{
        qDebug()<<"avformat_find_stream_info success";
    }
    //4.判断视频流
    this->video_input = -1;
    for (int i = 0;i < this->formatContext->nb_streams;i++) {
        if(this->formatContext->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
            this->video_input = i;
            break;
        }
    }
    if(video_input==-1){
        qDebug()<<"video_input no found";
        return;
    }else {
        qDebug()<<"video_input found success video_input ="<<video_input;
    }
    //5.查找解码器
    this->codeContext = this->formatContext->streams[video_input]->codec;
    this->decoder = avcodec_find_decoder(this->codeContext->codec_id);
    if(this->decoder == nullptr){
        qDebug()<<"avcodec_find_decoder failed";
        return;
    }else {
        qDebug()<<"avcodec_find_decoder success";
    }
    //6.打开解码器
    res = avcodec_open2(this->codeContext,this->decoder,nullptr);   //成功返回0
    if(res != 0){
        qDebug()<<"avcodec_open2 failed";
        return;
    }else {
        qDebug()<<"avcodec_open2 success";
    }

    //RGB初始化衔接
    initRGB();
    //YUV初始化衔接
    initYUV();

}

//RGB 像素数据 准备工作
void DecodeVideo::initRGB()
{
    int res = 0;
    //解码后准备
    //7.码流数据、像素数据 初始化 该操作必须在RGB和YUV之前
    this->packet = (AVPacket *)malloc(sizeof(AVPacket));
    this->size = this->codeContext->width * this->codeContext->height;
    av_new_packet(this->packet,this->size);
    if(res != 0){
        qDebug()<<"av_new_packet failed";
        return;
    }else {
        qDebug()<<"av_new_packet success";
    }
    //像素数据初始化
    this->picture = av_frame_alloc();

    //RGB操作
    this->pictureRGB = av_frame_alloc();
    //像素数据信息设置  必须使用原解码器上下文环境中获取
    this->pictureRGB->width = this->codeContext->width;
    this->pictureRGB->height = this->codeContext->height;
    this->pictureRGB->format = this->codeContext->pix_fmt;
    //解码缓冲区
    this->imgByteRGB = avpicture_get_size(AV_PIX_FMT_RGB32,
                                          this->codeContext->width,
                                          this->codeContext->height);
    this->bufferRGB = (uint8_t *)av_malloc(this->imgByteRGB * sizeof (uint8_t));
    avpicture_fill((AVPicture *)this->pictureRGB,
                   this->bufferRGB,
                   AV_PIX_FMT_RGB32,
                   this->codeContext->width,
                   this->codeContext->height);

    //制定RGB图像规则
    this->SwsContextRGB = sws_getContext(this->codeContext->width,
                                         this->codeContext->height,
                                         this->codeContext->pix_fmt,
                                         this->codeContext->width,
                                         this->codeContext->height,
                                         AV_PIX_FMT_RGB32,
                                         SWS_BICUBIC,
                                         nullptr,nullptr,nullptr);

    qDebug()<<"RGB准备工作完成";
}

//YUV 像素数据 准备工作
void DecodeVideo::initYUV()
{
    this->pictureYUV = av_frame_alloc();
    //像素数据信息设置  必须使用原解码器上下文环境中获取
    this->pictureYUV->width = this->codeContext->width;
    this->pictureYUV->height = this->codeContext->height;
    this->pictureYUV->format = this->codeContext->pix_fmt;
    //解码缓冲区
    this->imgByteYUV = avpicture_get_size(AV_PIX_FMT_YUV420P,
                                          this->codeContext->width,
                                          this->codeContext->height);
    this->bufferYUV = (uint8_t *)av_malloc(this->imgByteYUV * sizeof (uint8_t));
    avpicture_fill((AVPicture *)this->pictureYUV,
                   this->bufferYUV,
                   AV_PIX_FMT_YUV420P,
                   this->codeContext->width,
                   this->codeContext->height);

    //制定YUV图像规则
    this->SwsContextYUV= sws_getContext(this->codeContext->width,
                                         this->codeContext->height,
                                         this->codeContext->pix_fmt,
                                         this->codeContext->width,
                                         this->codeContext->height,
                                         AV_PIX_FMT_YUV420P,
                                         SWS_BICUBIC,
                                         nullptr,nullptr,nullptr);

    qDebug()<<"YUV准备工作完成";
}


void DecodeVideo::run()
{
    FILE * YUVfp = fopen("../fileout/test.yuv","wb+");
    int x=0;
    //8.从视频文件中读取一帧压缩数据  进行解码
    while(av_read_frame(this->formatContext,this->packet) == 0){
        //判断读到的码流数据 是否为视频流
        //packedt=压缩数据
        if(this->packet->stream_index == this->video_input){
            int get_picture_ptr = -1;
            //将一帧的压缩数据进行解码
            /*
             * this->packet=一帧压缩数据
             * this->picture=存放解压后的数据
             */
            avcodec_decode_video2(this->codeContext,this->picture,&get_picture_ptr,this->packet);

            if(get_picture_ptr != 0){
                //解码出来的数据   转成pictureRGB
                sws_scale(this->SwsContextRGB,
                          this->picture->data,
                          this->picture->linesize,
                          0,
                          this->picture->height,
                          this->pictureRGB->data,
                          this->pictureRGB->linesize);

                this->frame = QImage((uchar *)this->bufferRGB,
                                     this->codeContext->width,
                                     this->codeContext->height,
                                     QImage::Format_RGB32);
                //将QImage 保存成图片文件
                this->frame.save(QString("../fileout/%1.jpg").arg(x));
//                qDebug()<<"decoding picture num = "<<x;
                //传出信号
                emit sendImage(this->frame);

                msleep(40);

                //解码出来的数据   转成pictureYUV
                sws_scale(this->SwsContextYUV,
                          this->picture->data,
                          this->picture->linesize,
                          0,
                          this->picture->height,
                          this->pictureYUV->data,
                          this->pictureYUV->linesize);

                emit sendYUV(this->pictureYUV);

                //UV分量合起来是Y分量的1/2
                //U/V单独是Y分量的1/4
                //Y分量
                fwrite(this->pictureYUV->data[0],this->size,1,YUVfp);
                //U分量
                fwrite(this->pictureYUV->data[1],this->size/4,1,YUVfp);
                //V分量
                fwrite(this->pictureYUV->data[2],this->size/4,1,YUVfp);

//                qDebug()<<"保存一帧YUV  当前num："<<x;
                x++;
            }
        }

    }
    fclose(YUVfp);
    qDebug()<<"YUV文件保存成功";
    qDebug()<<"总计YUV数："<<x;
    qDebug()<<"总计RGB图片数："<<x;
    qDebug()<<"finish decoding";
    //释放解码器
    avcodec_close(this->codeContext);
    //释放文件
    avformat_close_input(&(this->formatContext));
    qDebug()<<"decoding release";
    emit sendClose();
}
