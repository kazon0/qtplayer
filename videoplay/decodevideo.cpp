#include "decodevideo.h"

DecodeVideo::DecodeVideo() :QThread ()
{
    //1.注册组件 有且仅有一次足矣
    av_register_all();

    this->initDecode();
}

//void DecodeVideo::initDecode(char *filepath)
void DecodeVideo::initDecode()
{
    int res = -1;
    //2.打开视频文件
    this->formatContext = avformat_alloc_context();
    res = avformat_open_input(&(this->formatContext),"../video/Warcraft3_End.avi",nullptr,nullptr);
    if(res != 0){
        qDebug()<<"avformat_open_input fail";
        return;
    }
    else{
        qDebug()<<"avformat_open_input uccess";
    }
    //3.获取视频信息
    res = avformat_find_stream_info(this->formatContext,nullptr);
    if(res < 0){
        qDebug()<<"avformat_find_stream_info fail";
        return;
    }
    else{
        qDebug()<<"avformat_find_stream_info uccess";
    }
    //4.判断视频流
    this->video_input = -1;
    for (int i =0;i<this->formatContext->nb_streams;i++) {
        if(this->formatContext->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
            this->video_input = i;
            break;
        }
    }

    if(this->video_input == -1){
        qDebug()<<"video_input nor find";
        return;
    }else{
        qDebug()<<"video_input find video_input"<<video_input;
    }
    //c5.查找解码器
    this->codecContext = this->formatContext->streams[video_input]->codec;
    this->decoder = avcodec_find_decoder(this->codecContext->codec_id);
    if(this->decoder == nullptr){
        qDebug()<<"avcodec_find_decoder nor find";
        return;
    }else{
        qDebug()<<"avcodec_find_decoder success";
    }
    //6.打开解码器
    res = avcodec_open2(this->codecContext,this->decoder,nullptr);
    if(res!=0){
        qDebug()<<"avcodec_open2 nor find";
        return;
    }else{
        qDebug()<<"avcodec_open2 success";
    }
    initRGB();

    //initYUV();
}
//RGB 像素数据 准备工作
void DecodeVideo::initRGB()
{
    int res =0;
    //7.码流数据 像素数据 初始化
    this->packet = (AVPacket *)malloc(sizeof(AVPacket));
    this->size = this->codecContext->width * this->codecContext->height;
    av_new_packet(this->packet,this->size);
    if(res !=0){
        qDebug()<<"av_new_packet fail";
    }
    else{
        qDebug()<<"av_new_packet success";
    }
    //像素数据初始化
    this->pictrue = av_frame_alloc();
    this->pictureRGB = av_frame_alloc();
    //像素数据信息设置必须使用原解码上下文环境中获取
    this->pictureRGB->width = this->codecContext->width;
    this->pictureRGB->height = this->codecContext->height;
    this->pictureRGB->format = this->codecContext->pix_fmt;
    //解码缓冲区
    this->imgByteRGB = avpicture_get_size(AV_PIX_FMT_RGB32,
                                          this->codecContext->width,
                                          this->codecContext->height);
    this->bufferRGB = (uint8_t *)av_malloc(this->imgByteRGB * sizeof (uint8_t));
    avpicture_fill((AVPicture *)this->pictureRGB,this->bufferRGB,AV_PIX_FMT_RGB32,
                   this->codecContext->width,
                   this->codecContext->height);
    //制定RGB图像规则，
    this->SwsContextRGB = sws_getContext(this->codecContext->width,
                                         this->codecContext->height,
                                         this->codecContext->pix_fmt,
                                         this->codecContext->width,
                                         this->codecContext->height,
                                         AV_PIX_FMT_RGB32,SWS_BICUBIC,
                                         nullptr,nullptr,nullptr);
    qDebug()<<"RGB准备工作完成";

}

void DecodeVideo::initYUV()
{
    this->pictureYUV = av_frame_alloc();
    //像素数据信息设置必须使用原解码上下文环境中获取
    this->pictureYUV->width = this->codecContext->width;
    this->pictureYUV->height = this->codecContext->height;
    this->pictureYUV->format = this->codecContext->pix_fmt;
    //解码缓冲区
    this->imgByteYUV = avpicture_get_size(AV_PIX_FMT_YUV420P,
                                          this->codecContext->width,
                                          this->codecContext->height);
    this->bufferYUV = (uint8_t *)av_malloc(this->imgByteYUV*sizeof (uint8_t));
    avpicture_fill((AVPicture *)this->pictureYUV,bufferYUV,AV_PIX_FMT_YUV420P,
                   this->codecContext->width,this->codecContext->height);
    this->SwsContextUVY = sws_getContext(this->codecContext->width,
                                         this->codecContext->height,
                                         this->codecContext->pix_fmt,
                                         this->codecContext->width,
                                         this->codecContext->height,
                                         AV_PIX_FMT_YUV420P,SWS_BICUBIC,
                                         nullptr,nullptr,nullptr);
    qDebug()<<"YUV准备工作完成";
}

void DecodeVideo::Decodeing()
{
    FILE * YUVfp = fopen("../fileout/test.yuv","wb+");
    int x =0;
    //8.从视频文件中读取一帧压缩数据，进行解码
    while(av_read_frame(this->formatContext,this->packet)==0){
        //判断读到的码流数据 是否为视频流
        if(this->packet->stream_index == this->video_input){
            int get_picture_ptr =-1;
            avcodec_decode_video2(this->codecContext,this->pictrue,&get_picture_ptr,this->packet);
            if(get_picture_ptr !=0){
//                //解码出来的数据 转 RGB
                sws_scale(this->SwsContextRGB,this->pictrue->data,
                          this->pictrue->linesize,0,this->pictrue->height,
                          this->pictureRGB->data,this->pictureRGB->linesize);

                this->frame = QImage((uchar *)this->bufferRGB,
                                     this->codecContext->width,
                                     this->codecContext->height,
                                     QImage::Format_RGB32);

                //qimage保存成图片文件
               // this->frame.save(QString("../fileout/%1.jpg").arg(x));


                //解码出来的数据 转 YUV
//                sws_scale(this->SwsContextUVY,this->pictrue->data,
//                          this->pictrue->linesize,0,this->pictrue->height,
//                          this->pictureYUV->data,this->pictureYUV->linesize);
//                //UV两个分量合起来是Y的分量的1/2
//                //U分量或V分量单独是Y的1/4

//                fwrite(this->pictureYUV->data[0],this->size,1,YUVfp);//Y分量
//                fwrite(this->pictureYUV->data[1],this->size/4,1,YUVfp);//U分量
//                fwrite(this->pictureYUV->data[2],this->size/4,1,YUVfp);//V分量

                x++;
                qDebug()<<"解码保存1帧图片 x ="<<x;
            }
        }
    }

//    fclose(YUVfp);
//    qDebug()<<"YUV文件保存成功";
    //释放解码器
    avcodec_close(this->codecContext);
    //释放文件
    avformat_close_input(&(this->formatContext));
    qDebug()<<"解码完成 x="<<x;
}

void DecodeVideo::run()
{
      int x =0;
    //8.从视频文件中读取一帧压缩数据，进行解码
    while(av_read_frame(this->formatContext,this->packet)==0){
        //判断读到的码流数据 是否为视频流
        if(this->packet->stream_index == this->video_input){
            int get_picture_ptr =-1;
            avcodec_decode_video2(this->codecContext,this->pictrue,&get_picture_ptr,this->packet);
            if(get_picture_ptr !=0){
//                //解码出来的数据 转 RGB
                sws_scale(this->SwsContextRGB,this->pictrue->data,
                          this->pictrue->linesize,0,this->pictrue->height,
                          this->pictureRGB->data,this->pictureRGB->linesize);

                this->frame = QImage((uchar *)this->bufferRGB,
                                     this->codecContext->width,
                                     this->codecContext->height,
                                     QImage::Format_RGB32);

                //发出自定义信号
                emit sendImage(this->frame);
                msleep(40);

                x++;
                qDebug()<<"解码保存1帧图片 x ="<<x;
            }
        }
    }

    //释放解码器
    avcodec_close(this->codecContext);
    //释放文件
    avformat_close_input(&(this->formatContext));
    qDebug()<<"解码完成 x="<<x;
}
